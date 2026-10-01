#!/usr/bin/env python3
"""Builds docs/aso/proposal.json from the measured terms.

Usage: propose.py brief   -> data/writer-brief.json (must-contain terms per locale)
       propose.py final   -> proposal.json (merges data/writers/*.json subtitles, promo)

Keyword fields: candidates in priority order; words already in the name or
subtitle are dropped, then the list is cut at 100 UTF-8 bytes.
Every "why" cites a row of keywords.md (live rank R, results n, median ratings m).
"""
import glob
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ASO = os.path.dirname(HERE)
META = os.path.join(ASO, "..", "..", "fastlane", "metadata")
STOREFRONTS = json.load(open(os.path.join(HERE, "storefront-locales.json")))

# locale: name, subtitle (English only; others are written blind), must-contain
# subtitle terms, frame-1 caption terms, keyword candidates, why.
SPEC = {
    "en-US": dict(
        name="Cutling - Clipboard Keyboard", subtitle="Paste Text Snippets & Replies",
        cap1="Clipboard keyboard for snippets",
        kw="canned,response,quick,history,manager,expander,notes,copy,shortcuts,autotext,autofill,replacement,signature,phrase",
        why="US: 'clipboard keyboard' R12 (n250, m235) is held by the name; keep it. 'text snippets' R25 and "
            "'canned responses' R24 already rank; 'quick reply' (m1), 'clipboard history' (m3), 'text expander' "
            "(m1) and 'notes keyboard' (m12) are relevant and uncrowded, so their words fill the field. "
            "Dead words from 1.5.4 (clip, quick-alone, address, template) leave."),
    "en-GB": dict(
        name="Cutling - Clipboard Keyboard", subtitle="Copy & Paste Text Snippets",
        cap1="Clipboard keyboard for snippets",
        kw="canned,response,quick,reply,history,manager,expander,notes,shortcuts,autotext,autofill,replacement,phrase",
        why="en-GB is listed in 172 of 175 storefronts, so it carries the English core everywhere except the US, "
            "Canada and Japan. GB: 'copy paste' (m622) is the biggest relevant English term the US subtitle "
            "lacks; 'canned response' R33; 'clipboard history' m1, 'text expander' m0, 'quick reply' m0."),
    "en-AU": dict(
        name="Cutling - Copy Paste Keyboard", subtitle="Saved Replies & Clipboard Text",
        cap1="Copy paste keyboard",
        kw="snippet,template,signature,iban,email,address,bank,booking,wifi,notepad,typing,quickpaste",
        why="Australia indexes en-AU with en-GB. en-GB already holds 'clipboard keyboard' and the canned/quick/"
            "history set, so en-AU takes 'copy paste keyboard' (AU type-ahead 'copy paste clipboard keyboard' "
            "is suggestion 1) and words en-GB lacks."),
    "en-CA": dict(
        name="Cutling - Clipboard Keyboard", subtitle="Paste Text Snippets & Replies",
        cap1="Clipboard keyboard for snippets",
        kw="canned,response,copy,quick,history,manager,expander,notes,shortcuts,autotext,autofill,phrase",
        why="Canada indexes only en-CA and fr-CA (no en-GB), so en-CA must carry the full English set itself. "
            "CA: 'canned responses' R45, 'clipboard keyboard' R98, 'clipboard history+' type-ahead 1."),
    "en-IN": dict(
        name="Cutling - Clipboard Keyboard", subtitle="Copy & Paste Text Snippets",
        cap1="Clipboard keyboard for snippets",
        kw="canned,response,quick,reply,history,manager,expander,notes,shortcuts,autotext,autofill,phrase",
        why="Apple's table lists en-IN in no storefront; India indexes en-GB plus eleven Indian-language "
            "locales. Kept consistent with en-GB for anyone shown it."),
    # Spanish, Portuguese, French, Italian, Dutch, German
    "es-MX": dict(name="Cutling - Teclado portapapeles", must="copiar y pegar, respuestas rápidas",
        cap1="Teclado portapapeles", kw="copiar,pegar,respuestas,rápidas,textos,plantillas,notas,autorrellenar,atajos,frases,firma",
        why="MX: 'portapapeles teclado' R11, 'portapapeles teclado pegar' R24, 'copiar pegar' R101; es-MX is also "
            "indexed in 18 other Latin American storefronts and in the US."),
    "es-ES": dict(name="Cutling - Teclado portapapeles", must="copiar y pegar, respuestas rápidas",
        cap1="Teclado portapapeles", kw="copiar,pegar,respuestas,rápidas,textos,plantillas,notas,autorrellenar,atajos,frases",
        why="ES: 'portapapeles teclado pegar' R38, 'portapapeles' R65 (m12), 'copiar pegar' R131; "
            "'respuestas rápidas' n21 is nearly empty."),
    "ca": dict(name="Cutling - Teclat porta-retalls", must="copiar i enganxar",
        cap1="Teclat porta-retalls", kw="copiar,enganxar,respostes,ràpides,textos,plantilles,notes,dreceres,adreça",
        why="Spain indexes ca with es-ES and en-GB; Catalan field adds Catalan forms (ES: 'drecera' R24, 'adreça' R37)."),
    "pt-BR": dict(name="Cutling - Teclado copiar colar", must="respostas rápidas, área de transferência",
        cap1="Teclado para copiar e colar", kw="respostas,rápidas,área,transferência,mensagens,prontas,frases,atalhos,textos,notas",
        why="BR: 'copiar colar' n249 but median ratings 0 (open), Cutling R210; 'respostas rápidas' R63; "
            "'área de transferência' rel10 m10 unranked. pt-BR is also indexed in the US."),
    "pt-PT": dict(name="Cutling - Teclado copiar colar", must="respostas rápidas",
        cap1="Teclado para copiar e colar", kw="respostas,rápidas,área,transferência,atalhos,textos,frases,notas,morada",
        why="PT: 'respostas rápidas' R35, 'atalhos de texto' R54, 'copiar colar' R117, 'área de transferência' m0."),
    "fr-FR": dict(name="Cutling - Copier-coller", must="clavier, presse-papiers",
        cap1="Clavier copier-coller", kw="réponses,rapides,raccourcis,texte,modèles,extraits,notes,remplissage,presse,papiers",
        why="FR: 'clavier copier coller' R59, 'clavier presse-papiers' R61, 'raccourcis texte' R94, "
            "'réponses rapides' n26 (open). fr-FR is indexed in 32 storefronts including the US."),
    "fr-CA": dict(name="Cutling - Copier-coller", must="clavier, presse-papiers",
        cap1="Clavier copier-coller", kw="presse,papiers,réponses,rapides,raccourcis,texte,modèles,extraits,notes",
        why="Canada indexes fr-CA with en-CA. CA: 'presse-papiers' rel10 m1, 'copier coller' m9, 'extrait' R116."),
    "it": dict(name="Cutling - Tastiera appunti", must="copia incolla, risposte rapide",
        cap1="Tastiera appunti", kw="copia,incolla,risposte,rapide,testi,frasi,modelli,note,scorciatoie,indirizzo,messaggi,predefiniti,firma,compilazione",
        why="IT: 'tastiera appunti' R14, 'risposte rapide' R21, 'copia incolla' R75 (m13)."),
    "nl-NL": dict(name="Cutling - Klembord toetsenbord", must="kopiëren en plakken",
        cap1="Klembord toetsenbord", kw="kopiëren,plakken,snelle,antwoorden,tekst,sjablonen,notities,tekstvervanging",
        why="NL: 'klembord' R24, 'kopiëren plakken' R26 (m0); nl-NL is also indexed in Belgium and Suriname."),
    "de-DE": dict(name="Cutling - Zwischenablage", must="Tastatur, Textbausteine",
        cap1="Zwischenablage-Tastatur", kw="kopieren,einfügen,schnellantworten,notizen,vorlagen,textersetzung,kurzbefehle,adresse,signatur",
        why="DE: 'Zwischenablage Tastatur' R53 (m5), 'Zwischenablage' R170, 'Schnellantworten' R50, "
            "'Textbausteine' n59 rel9 m0 unranked (open). de-DE also covers AT, CH, LU."),
    # Nordic and central European
    "sv": dict(name="Cutling - Urklipp tangentbord", must="kopiera och klistra in, snabbsvar",
        cap1="Urklipp på tangentbordet", kw="kopiera,klistra,snabbsvar,anteckningar,autofyll,textgenvägar,mallar,historik",
        why="SE: 'urklipp' R18, 'anteckningar tangentbord' R12, 'autofyll' R9, 'kopiera klistra in' n31 m0."),
    "da": dict(name="Cutling - Udklipsholder", must="tastatur, kopiér og indsæt",
        cap1="Udklipsholder på tastaturet", kw="kopiér,indsæt,hurtige,svar,tekst,skabeloner,noter,genveje,udfyldning,signatur,adresse,beskeder",
        why="DK: 'udklipsholder' R33 (m0)."),
    "no": dict(name="Cutling - Utklippstavle", must="tastatur, kopier og lim inn",
        cap1="Utklippstavle på tastaturet", kw="kopier,lim,inn,hurtigsvar,tekst,maler,notater,snarveier,utfylling,signatur,adresse,meldinger",
        why="NO: 'utklippstavle' R25 (m0)."),
    "fi": dict(name="Cutling - Leikepöytä", must="näppäimistö, kopioi ja liitä",
        cap1="Leikepöytä näppäimistössä", kw="kopioi,liitä,pikavastaukset,tekstit,pohjat,muistiinpanot,täyttö,allekirjoitus,osoite,viestit",
        why="FI: 'täyttö' R39; 'näppäimistö' rel10 m87; Finnish clipboard term in the name."),
    "pl": dict(name="Cutling - Schowek klawiatura", must="kopiuj wklej, szybkie odpowiedzi",
        cap1="Schowek na klawiaturze", kw="kopiuj,wklej,szybkie,odpowiedzi,skróty,tekstowe,szablony,notatki,autouzupełnianie",
        why="PL: 'schowek' R20, 'kopiuj wklej' R35 (m1)."),
    "cs": dict(name="Cutling - Schránka klávesnice", must="kopírovat a vložit",
        cap1="Schránka v klávesnici", kw="kopírovat,vložit,rychlé,odpovědi,šablony,poznámky,zkratky,textové",
        why="CZ: 'schránka' R10, 'kopírovat vložit' R19."),
    "sk": dict(name="Cutling - Schránka klávesnica", must="kopírovať a vložiť",
        cap1="Schránka v klávesnici", kw="kopírovať,vložiť,rýchle,odpovede,šablóny,poznámky,skratky,vyplnenie,podpis,adresa",
        why="SK: 'clipboard keyboard' R42 via en-GB; Slovak name terms added."),
    "hu": dict(name="Cutling - Vágólap billentyűzet", must="másolás és beillesztés",
        cap1="Vágólap a billentyűzeten", kw="másolás,beillesztés,gyors,válaszok,sablonok,jegyzetek,szöveg,kitöltés,aláírás,cím,üzenetek",
        why="HU: English 'clipboard keyboard' R44 via en-GB; Hungarian terms measured thin (n<250, rel low)."),
    "ro": dict(name="Cutling - Tastatură clipboard", must="copiere și lipire",
        cap1="Tastatură clipboard", kw="copiere,lipire,răspunsuri,rapide,șabloane,notițe,text,adresă",
        why="RO: 'clipboard keyboard' R47; Romanian users type the English 'clipboard'."),
    "hr": dict(name="Cutling - Kopiraj i zalijepi", must="međuspremnik, tipkovnica",
        cap1="Kopiraj i zalijepi tipkovnicom", kw="lijepljenje,kopiranje,brzi,odgovori,predlošci,bilješke,isječci",
        why="HR: 'lijepljenje' R7, 'kopiranje' R24; hr is also indexed in BA, ME, RS."),
    "sl-SI": dict(name="Cutling - Odložišče tipkovnica", must="kopiraj in prilepi",
        cap1="Odložišče na tipkovnici", kw="kopiraj,prilepi,hitri,odgovori,predloge,beležke,besedilo,izpolnjevanje,podpis,naslov",
        why="SI: Slovenian terms returned 0-1 results; English via en-GB ranks ('clipboard keyboard' R32)."),
    "el": dict(name="Cutling - Αντιγραφή επικόλληση", must="πρόχειρο, πληκτρολόγιο",
        cap1="Αντιγραφή και επικόλληση", kw="πρόχειρο,γρήγορες,απαντήσεις,πρότυπα,σημειώσεις,διεύθυνση",
        why="GR: 'επικόλληση' R44 (m0), 'σημείωση' R140."),
    "tr": dict(name="Cutling - Kopyala Yapıştır", must="klavye, hızlı yanıt",
        cap1="Kopyala yapıştır klavyesi", kw="hızlı,yanıt,pano,metin,kısayolu,hazır,mesaj,şablon,notlar,otomatik,doldur",
        why="TR: 'hızlı yanıt' R18, 'kopyala yapıştır' R114, 'metin kısayolu' n30 m1 (open)."),
    "ru": dict(name="Cutling - Буфер обмена", must="клавиатура, быстрые ответы",
        cap1="Клавиатура с буфером обмена", kw="копировать,вставить,шаблоны,заметки,автозаполнение,фразы,текст",
        why="RU: 'заметки клавиатура' R39, 'буфер обмена клавиатура' n40 m1 (open); ru is also indexed in UA and the US."),
    "uk": dict(name="Cutling - Буфер обміну", must="клавіатура, копіювати й вставити",
        cap1="Клавіатура з буфером обміну", kw="клавіатура,копіювати,вставити,швидкі,відповіді,шаблони,нотатки,автозаповнення",
        why="UA: 'копіювати вставити' R25, 'буфер обміну' n41 m0."),
    "bg": dict(name="Cutling - Клипборд клавиатура", must="копиране и поставяне",
        cap1="Клипборд клавиатура", kw="копиране,поставяне,шаблон,текст,бележки,бързи,отговори",
        why="Apple lists bg in no storefront; Bulgaria indexes en-GB. Kept tidy for display."),
    "sr": dict(name="Cutling - Клипборд тастатура", must="копирај и налепи",
        cap1="Клипборд тастатура", kw="копирај,налепи,шаблон,брзи,одговори,белешке",
        why="Apple lists sr in no storefront; Serbia indexes hr and en-GB."),
    "et": dict(name="Cutling - Lõikelaua klaviatuur", must="kopeeri ja kleebi",
        cap1="Lõikelaud klaviatuuris", kw="kopeeri,kleebi,kiirvastused,mallid,märkmed",
        why="Apple lists et in no storefront; Estonia indexes en-GB."),
    "lt": dict(name="Cutling - Iškarpinė klaviatūra", must="kopijuoti ir įklijuoti",
        cap1="Iškarpinė klaviatūroje", kw="kopijuoti,įklijuoti,greiti,atsakymai,šablonai,užrašai",
        why="Apple lists lt in no storefront; Lithuania indexes en-GB."),
    "lv": dict(name="Cutling - Starpliktuve", must="tastatūra, kopēt un ielīmēt",
        cap1="Starpliktuve tastatūrā", kw="kopēt,ielīmēt,ātrās,atbildes,veidnes,piezīmes",
        why="Apple lists lv in no storefront; Latvia indexes en-GB."),
    # Asia
    "ja": dict(name="Cutling - コピペ・定型文キーボード", must="クリップボード",
        cap1="定型文をキーボードからコピペ", kw="クリップボード,履歴,スニペット,ペースト,辞書,返信,テンプレ",
        why="JP: 'クリップボード履歴' R31, 'クリップボード' R35, 'コピペ' R43 (m38), '定型文 キーボード' R66 (m3); "
            "Japan also indexes en-US."),
    "ko": dict(name="Cutling - 클립보드 복붙 키보드", must="자주 쓰는 문구",
        cap1="복붙 키보드로 문구 입력", kw="정형문,상용구,스니펫,자동입력,메모,문구저장,답장",
        why="KR: '정형문' R6, '복붙키보드' R48, '스니펫' R56, '자동입력' R103, '자주쓰는문구' n31 m0; ko is also indexed in the US."),
    "zh-Hans": dict(name="Cutling - 剪贴板输入法", must="常用语, 复制粘贴",
        cap1="剪贴板输入法", kw="快捷短语,常用文字,自动填充,管理,模板,键盘",
        why="CN: '剪贴板输入法' R12, '自动填充' R18, '剪贴板管理' R22, '常用文字' R25, '复制粘贴' R33; also indexed in SG and the US."),
    "zh-Hant": dict(name="Cutling - 剪貼簿鍵盤", must="常用語, 複製貼上",
        cap1="剪貼簿鍵盤", kw="常用文字,快捷短語,自動填寫,輸入法,範本,罐頭訊息",
        why="TW: 'clipboard 剪貼簿 鍵盤' R18, '自動填寫' R15, '常用文字' R23, '常用語' rel10 m1 unranked; also HK, MO, US."),
    "th": dict(name="Cutling - คีย์บอร์ดคลิปบอร์ด", must="คัดลอกวาง, ข้อความสำเร็จรูป",
        cap1="คีย์บอร์ดคลิปบอร์ด", kw="ตอบกลับด่วน,บันทึก,แม่แบบ,ข้อความ",
        why="TH: 'คลิปบอร์ด' R49, 'คัดลอกวาง' R75, 'ข้อความสำเร็จรูป' n14 rel10 m0 (open)."),
    "vi": dict(name="Cutling - Bàn phím sao chép", must="bộ nhớ tạm, tin nhắn mẫu",
        cap1="Bàn phím sao chép, dán nhanh", kw="dán,trả,lời,nhanh,văn,bản,mẫu,ghi,chú,địa,chỉ,chữ,ký,điền,tự,động",
        why="VN: 'tin nhắn mẫu' R86, 'sao chép văn bản' R121, 'bộ nhớ tạm' n43 m0; vi is also indexed in the US."),
    "id": dict(name="Cutling - Salin Tempel", must="keyboard, balasan cepat",
        cap1="Keyboard salin tempel", kw="papan,klip,teks,cepat,catatan,template,isi,otomatis,alamat,rekening",
        why="ID: 'catatan keyboard' R19, 'salin tempel' R39, 'teks cepat' R61, 'papan klip' rel10 m36, "
            "'balasan cepat' n16 m0 (open)."),
    "ms": dict(name="Cutling - Salin Tampal", must="papan klip, balasan pantas",
        cap1="Salin tampal dari papan kekunci", kw="teks,pantas,papan,kekunci,keratan,nota,templat,isi,automatik,alamat,mesej,tandatangan",
        why="MY: 'salin tampal' R33, 'teks pantas' R48, 'papan keratan' n27 m0."),
    "fil": dict(name="Cutling - Clipboard Keyboard", must="kopya at paste",
        cap1="Clipboard keyboard", kw="mabilis,sagot,teksto,template,tala",
        why="Apple lists fil in no storefront; the Philippines indexes en-GB."),
    "ar-SA": dict(name="Cutling - لوحة مفاتيح الحافظة", must="نسخ ولصق, ردود سريعة",
        cap1="لوحة مفاتيح الحافظة", kw="نصوص,جاهزة,قصاصة,ملاحظات,قوالب,الملء,التلقائي",
        why="SA: 'قصاصة' R31, 'الحافظة' R95, 'نسخ ولصق' n191 m12, 'نصوص جاهزة' n14 m0; ar-SA is indexed in 17 Arab storefronts and the US."),
    "he": dict(name="Cutling - מקלדת העתק הדבק", must="תשובות מהירות",
        cap1="מקלדת העתק הדבק", kw="לוח,גזירים,קיצורי,טקסט,קטעים,תבניות,הערות",
        why="IL: 'העתק הדבק' R17, 'קטע' R23; 'קיצורי טקסט' and 'לוח גזירים' n5-6 (open)."),
    "fa": dict(name="Cutling - کیبورد کلیپ‌بورد", must="کپی و چسباندن",
        cap1="کیبورد کلیپ‌بورد", kw="متن,آماده,پاسخ,سریع,یادداشت",
        why="Apple lists fa in no storefront and Iran has none."),
    "ur-PK": dict(name="Cutling - کلپ بورڈ کی بورڈ", must="کاپی پیسٹ",
        cap1="کلپ بورڈ کی بورڈ", kw="copy,paste,manager,history,quick,reply,snippets,autofill,notes",
        why="Pakistan indexes ur-PK with en-GB; PK: 'clipboard manager' R230, 'autofill' R190. Urdu-script terms "
            "returned crowded unrelated results, so the field carries English words that en-GB's field lacks room for."),
    "sw": dict(name="Cutling - Kibodi ya Clipboard", must="nakili na bandika",
        cap1="Kibodi ya clipboard", kw="nakili,bandika,majibu,haraka,maandishi,violezo",
        why="Apple lists sw in no storefront; Kenya indexes en-GB."),
}

# India: en-GB plus eleven Indian-language locales. Local-script queries return 0-5 results
# (keywords.md, IN), so these fields carry English word groups that form phrases inside each locale.
INDIA = {
    "hi": ("क्लिपबोर्ड कीबोर्ड", "कॉपी पेस्ट", "clipboard,manager,copy,paste,history,keyboard,notes"),
    "mr-IN": ("क्लिपबोर्ड कीबोर्ड", "कॉपी पेस्ट", "text,snippets,quick,reply,canned,responses,saved"),
    "bn-BD": ("ক্লিপবোর্ড কীবোর্ড", "কপি পেস্ট", "autofill,template,shortcuts,phrases,autotext,expander"),
    "bn-IN": ("ক্লিপবোর্ড কীবোর্ড", "কপি পেস্ট", "autofill,template,shortcuts,phrases,autotext,expander"),
    "gu-IN": ("ક્લિપબોર્ડ કીબોર્ડ", "કૉપી પેસ્ટ", "copy,paste,keyboard,clipboard,saver,typing"),
    "ta-IN": ("கிளிப்போர்டு", "கீபோர்டு, காப்பி பேஸ்ட்", "notes,keyboard,signature,address,iban,email"),
    "te-IN": ("క్లిప్‌బోర్డ్", "కీబోర్డ్, కాపీ పేస్ట్", "clipboard,history,saver,recent,copies"),
    "kn-IN": ("ಕ್ಲಿಪ್‌ಬೋರ್ಡ್", "ಕೀಬೋರ್ಡ್, ಕಾಪಿ ಪೇಸ್ಟ್", "text,replacement,shortcut,typing,faster"),
    "ml-IN": ("ക്ലിപ്ബോർഡ് കീബോർഡ്", "കോപ്പി പേസ്റ്റ്", "quick,messages,replies,saved,customer"),
    "or-IN": ("କ୍ଲିପବୋର୍ଡ କୀବୋର୍ଡ", "କପି ପେଷ୍ଟ", "custom,keyboard,snippet,saver,widget"),
    "pa-IN": ("ਕਲਿੱਪਬੋਰਡ ਕੀਬੋਰਡ", "ਕਾਪੀ ਪੇਸਟ", "paste,keyboard,clipboard,manager,typing"),
}
for loc, (desc, must, kw) in INDIA.items():
    SPEC[loc] = dict(name=f"Cutling - {desc}", must=must, cap1=desc, kw=kw,
                     why="India indexes en-GB plus eleven Indian-language locales (Apple's table); IN measured "
                         "local-script terms at 0-5 results, so this field carries an English word group that "
                         "forms its own phrases ('clipboard manager' m39, 'copy paste' m24, 'quick reply' m4, "
                         "'text snippets' m1).")


def words(text):
    return {w for w in re.split(r"[\s,&・、/\-–—:]+", text.lower()) if w}


def build_keywords(name, subtitle, candidates):
    taken = words(name) | words(subtitle)
    out, size = [], 0
    for term in [t.strip() for t in candidates.split(",") if t.strip()]:
        if term.lower() in taken or term.lower() in [o.lower() for o in out]:
            continue
        extra = len(term.encode()) + (1 if out else 0)
        if size + extra > 100:
            continue
        out.append(term)
        size += extra
    return ",".join(out)


def current(loc, field):
    path = os.path.join(META, loc, f"{field}.txt")
    return open(path, encoding="utf-8").read().strip() if os.path.exists(path) else ""


def storefronts_for(loc):
    return sorted(k for k, v in STOREFRONTS.items() if loc in v)


def brief():
    out = {}
    for loc, s in SPEC.items():
        assert len(s["name"]) <= 30, (loc, s["name"], len(s["name"]))
        out[loc] = {"name": s["name"], "mustSubtitle": s.get("must", ""), "mustCaption1": s["cap1"]}
    json.dump(out, open(os.path.join(HERE, "writer-brief.json"), "w"), ensure_ascii=False, indent=1)
    print(f"brief for {len(out)} locales")


def final():
    written = {}
    for f in glob.glob(os.path.join(HERE, "writers", "*.json")):
        written.update(json.load(open(f)))
    english = json.load(open(os.path.join(HERE, "writers-en.json")))
    proposal = {}
    for loc, s in sorted(SPEC.items()):
        w = english.get(loc) or written.get(loc) or {}
        subtitle = s.get("subtitle") or w.get("subtitle", "")
        kw = build_keywords(s["name"], subtitle, s["kw"])
        promo = w.get("promo", "")
        entry = {
            "name": s["name"], "subtitle": subtitle, "keywords": kw, "promo": promo,
            "mustContain": s.get("must", ""), "storefronts": storefronts_for(loc), "why": s["why"],
            "before": {f: current(loc, f) for f in ("name", "subtitle", "keywords", "promotional_text")},
            "checks": {"nameChars": len(s["name"]), "subtitleChars": len(subtitle),
                       "keywordBytes": len(kw.encode()), "promoChars": len(promo)},
        }
        assert entry["checks"]["nameChars"] <= 30 and entry["checks"]["subtitleChars"] <= 30, (loc, entry["checks"])
        assert entry["checks"]["keywordBytes"] <= 100 and entry["checks"]["promoChars"] <= 170, (loc, entry["checks"])
        proposal[loc] = entry
    json.dump(proposal, open(os.path.join(ASO, "proposal.json"), "w"), ensure_ascii=False, indent=1)
    print(f"proposal for {len(proposal)} locales")


if __name__ == "__main__":
    {"brief": brief, "final": final}[sys.argv[1]]()
