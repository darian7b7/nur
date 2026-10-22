#!/usr/bin/env python3
"""Fills in the Arabic of Nūr's verses and hadith, and checks every text against its source.

    python3 tool/build_content.py

Reads and rewrites assets/content/lights.json. Nothing Arabic is typed by hand:
- Quran: the Uthmani text from quran.com, cut to the words given in "arabicFrom.quran"
  ("2:257:1-9" = words 1 to 9 of 2:257; "94:5 94:6" = two whole verses; " … " = a gap).
- Hadith: the Arabic of Sahih al-Bukhari / Sahih Muslim (fawazahmed0/hadith-api, the same texts as
  sunnah.com), from the first to the last words given in "arabicFrom.hadith" (pairs; diacritics ignored).
It also checks that every English verse is word for word Saheeh International, and every English
hadith word for word the sunnah.com English, and stops with an error if anything is off.
Downloads are kept in tool/.cache.
"""
import json
import os
import re
import sys
import unicodedata
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONTENT = os.path.join(ROOT, 'assets', 'content', 'lights.json')
CACHE = os.path.join(ROOT, 'tool', '.cache')
HADITH = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/{}.min.json'
AR_DIGITS = str.maketrans('0123456789', '٠١٢٣٤٥٦٧٨٩')
PAUSES = 'ۖۗۚۛۙۘ۞'


def fetch(url, name):
    os.makedirs(CACHE, exist_ok=True)
    path = os.path.join(CACHE, name)
    if not os.path.exists(path):
        req = urllib.request.Request(url, headers={'User-Agent': 'curl/8.5.0'})
        with urllib.request.urlopen(req, timeout=120) as r, open(path, 'wb') as f:
            f.write(r.read())
    with open(path, encoding='utf-8') as f:
        return json.load(f)


def verse(key):
    v = fetch(f'https://api.quran.com/api/v4/verses/by_key/{key}?words=true&word_fields=text_uthmani&translations=20',
              f'verse-{key.replace(":", "_")}.json')['verse']
    words = [w['text_uthmani'] for w in v['words'] if w['char_type_name'] == 'word']
    english = re.sub(r'<sup[^>]*>.*?</sup>', '', v['translations'][0]['text'])
    return words, re.sub('<[^>]+>', '', english)


def surah_name(n):
    return fetch(f'https://api.quran.com/api/v4/chapters/{n}?language=ar', f'chapter-{n}.json')['chapter']['name_arabic']


def clean(word):
    return word.strip(' ' + PAUSES).strip()


def quran_arabic(spec):
    """'24:35:1-4 … 24:35:33-40' -> the Arabic words, with ﴿n﴾ after each verse that is quoted to its end."""
    parts = []
    for gap, segment in enumerate(spec.split(' … ')):
        if gap:
            parts.append('…')
        for item in segment.split():
            s, a, *rng = item.split(':')
            words, _ = verse(f'{s}:{a}')
            first, last = (int(x) for x in rng[0].split('-')) if rng else (1, len(words))
            text = ' '.join(clean(w) for w in words[first - 1:last])
            parts.append(text + (f' ﴿{a.translate(AR_DIGITS)}﴾' if last == len(words) else ''))
    return ' '.join(parts)


def plain(s):
    """Arabic without diacritics and with one kind of alef, for finding words."""
    s = re.sub('[ً-ٰٟـۖ-ۭ]', '', s)
    return s.translate(str.maketrans('أإآٱىة', 'اااايه'))


def excerpt(text, first, last):
    """The original (with diacritics) from the words [first] to the words [last]."""
    keep = [i for i, c in enumerate(text) if plain(c)]
    flat = ''.join(plain(text[i]) for i in keep)
    a = flat.find(plain(first))
    b = flat.find(plain(last), a)
    if a < 0 or b < 0:
        raise SystemExit(f'Not found in the Arabic: {first!r} … {last!r}')
    end = keep[b + len(plain(last)) - 1] + 1
    while end < len(text) and re.match('[ً-ٰٟ]', text[end]):
        end += 1
    found = text[keep[a]:end].replace('\u200f', '').replace('"', '')
    return ' '.join(found.split()).strip(' ،,')


def norm_en(x):
    x = unicodedata.normalize('NFKD', x)
    x = ''.join(c for c in x if not unicodedata.combining(c))
    x = re.sub(r'\[i\.e\.,[^\]]*\]', '', x).replace('ﷺ', '')
    x = x.replace("(may peace be' upon him)", '').replace('(way peace be upon him)', '')
    return ' '.join(re.sub(r'[^a-z ]', ' ', x.lower()).split())


def in_order(part, whole):
    words, i = part.split(), 0
    for w in whole.split():
        if i < len(words) and w == words[i]:
            i += 1
    return i == len(words)


def main():
    data = json.load(open(CONTENT, encoding='utf-8'))
    bukhari = {str(h['hadithnumber']): h['text'] for h in fetch(HADITH.format('ara-bukhari'), 'ara-bukhari.json')['hadiths']}
    bukhari_en = {str(h['hadithnumber']): h['text'] for h in fetch(HADITH.format('eng-bukhari'), 'eng-bukhari.json')['hadiths']}
    muslim, muslim_en = {}, {}
    for h in fetch(HADITH.format('ara-muslim'), 'ara-muslim.json')['hadiths']:
        muslim.setdefault(str(h.get('arabicnumber', '')).split('.')[0], []).append(h['text'])
    for h in fetch(HADITH.format('eng-muslim'), 'eng-muslim.json')['hadiths']:
        muslim_en.setdefault(str(h.get('arabicnumber', '')).split('.')[0], []).append(h['text'])

    lights = [data['dawn'], *data['pool'], *data['long'], *data['hardDays'], *data['rains'], *data['why']]
    problems = []
    for l in lights:
        src = l['arabicFrom']
        if 'quran' in src:
            l['ar'] = quran_arabic(src['quran'])
            m = re.search(r'(\d+):(\d+)(?:–(\d+))?$', l['source'])
            s, a, b = m[1], m[2], m[3]
            official = norm_en(' '.join(verse(f'{s}:{v}')[1] for v in range(int(a), int(b or a) + 1)))
            for seg in l['en'].split('…'):
                if norm_en(seg) not in official:
                    problems.append(f'{l["source"]}: English is not word for word Saheeh International: {seg.strip()!r}')
            l['sourceAr'] = f'{surah_name(s)} {(a + ("–" + b if b else "")).translate(AR_DIGITS)}'
        else:
            n = l['source'].split()[-1]
            is_bukhari = 'Bukhari' in l['source']
            arabic = bukhari.get(n, '') if is_bukhari else ' '.join(muslim.get(n, []))
            english = norm_en(bukhari_en.get(n, '') if is_bukhari else ' '.join(muslim_en.get(n, [])))
            pairs = src['hadith']
            l['ar'] = ' … '.join(excerpt(arabic, pairs[i], pairs[i + 1]) for i in range(0, len(pairs), 2))
            for seg in l['en'].split('…'):
                if norm_en(seg) and not in_order(norm_en(seg), english):
                    problems.append(f'{l["source"]}: English differs from sunnah.com: {seg.strip()!r}')
            l['sourceAr'] = ('صحيح البخاري ' if is_bukhari else 'صحيح مسلم ') + n.translate(AR_DIGITS)
    if problems:
        print('\n'.join(problems))
        sys.exit(1)
    json.dump(data, open(CONTENT, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print(f'{len(lights)} lights: Arabic filled in, every English text checked against its source.')


if __name__ == '__main__':
    main()
