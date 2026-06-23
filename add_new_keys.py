#!/usr/bin/env python3
"""
Append the 12 new English keys (not yet present in non-English locale files)
across all 70 non-English locales with hand-written translations.

Idempotent: keys already present are skipped.
"""

import re
from pathlib import Path

REPO_ROOT = Path(__file__).parent
CUTLING_DIR = REPO_ROOT / "Cutling"

KEYS = [
    "Saved",
    "History",
    "No saved cutlings yet",
    "Copy something to see it here",
    "Clipboard history is off. Enable it in Settings.",
    "Spotlight",
    "Include in Spotlight Search",
    "Make your cutlings searchable from Spotlight. Sensitive content (credit cards, API keys, JWT tokens, seed phrases, private keys) is never indexed.",
    "Copy Cutling",
    "Copy a cutling's contents to the clipboard.",
    "Use these phrases with Siri or browse all Cutling shortcuts in the Shortcuts app.",
    'Copied "%@"',
]
assert len(KEYS) == 12

T = {}

# Order: Saved, History, No saved cutlings yet, Copy something to see it here,
# Clipboard history is off. Enable it in Settings., Spotlight,
# Include in Spotlight Search, Make your cutlings searchable from Spotlight ...,
# Copy Cutling, Copy a cutling's contents to the clipboard.,
# Use these phrases with Siri or browse all Cutling shortcuts in the Shortcuts app.,
# Copied "%@"

# ───────── Romance ─────────
T["es"] = (
    "Guardados", "Historial", "Aún no hay cutlings guardados",
    "Copia algo para verlo aquí", "El historial del portapapeles está desactivado. Actívalo en Ajustes.",
    "Spotlight", "Incluir en búsqueda de Spotlight",
    "Haz que tus cutlings sean buscables desde Spotlight. El contenido sensible (tarjetas de crédito, claves de API, tokens JWT, frases semilla, claves privadas) nunca se indexa.",
    "Copiar Cutling", "Copia el contenido de un cutling al portapapeles.",
    "Usa estas frases con Siri o explora todos los atajos de Cutling en la app Atajos.",
    "Copiado «%@»",
)
T["es-ES"] = T["es"]; T["es-MX"] = T["es"]

T["ca"] = (
    "Desats", "Historial", "Encara no hi ha cap cutling desat",
    "Copia alguna cosa per veure-la aquí", "L’historial del porta-retalls està desactivat. Activa’l a Ajustaments.",
    "Spotlight", "Incloure a la cerca d’Spotlight",
    "Fes que els teus cutlings es puguin cercar des de Spotlight. El contingut sensible (targetes de crèdit, claus d’API, tokens JWT, frases llavor, claus privades) mai no s’indexa.",
    "Copiar Cutling", "Copia el contingut d’un cutling al porta-retalls.",
    "Fes servir aquestes frases amb Siri o explora totes les dreceres de Cutling a l’app Dreceres.",
    "Copiat «%@»",
)

T["fr"] = (
    "Enregistrés", "Historique", "Aucun cutling enregistré",
    "Copie quelque chose pour le voir ici", "L’historique du presse-papiers est désactivé. Active-le dans Réglages.",
    "Spotlight", "Inclure dans la recherche Spotlight",
    "Rends tes cutlings cherchables depuis Spotlight. Le contenu sensible (cartes bancaires, clés d’API, jetons JWT, phrases mnémoniques, clés privées) n’est jamais indexé.",
    "Copier le Cutling", "Copie le contenu d’un cutling vers le presse-papiers.",
    "Utilise ces phrases avec Siri ou explore tous les raccourcis Cutling dans l’app Raccourcis.",
    "« %@ » copié",
)
T["fr-CA"] = T["fr"]; T["fr-FR"] = T["fr"]

T["it"] = (
    "Salvati", "Cronologia", "Nessun cutling salvato",
    "Copia qualcosa per vederlo qui", "La cronologia degli appunti è disattivata. Attivala in Impostazioni.",
    "Spotlight", "Includi nella ricerca Spotlight",
    "Rendi i tuoi cutling cercabili da Spotlight. Il contenuto sensibile (carte di credito, chiavi API, token JWT, frasi seed, chiavi private) non viene mai indicizzato.",
    "Copia Cutling", "Copia il contenuto di un cutling negli appunti.",
    "Usa queste frasi con Siri o esplora tutti i comandi rapidi Cutling nell’app Comandi rapidi.",
    "Copiato “%@”",
)

T["pt"] = (
    "Salvos", "Histórico", "Ainda não há cutlings salvos",
    "Copie algo para vê-lo aqui", "O histórico da área de transferência está desativado. Ative-o em Ajustes.",
    "Spotlight", "Incluir na busca do Spotlight",
    "Torne seus cutlings pesquisáveis no Spotlight. Conteúdo sensível (cartões de crédito, chaves de API, tokens JWT, frases-semente, chaves privadas) nunca é indexado.",
    "Copiar Cutling", "Copia o conteúdo de um cutling para a área de transferência.",
    "Use estas frases com a Siri ou explore todos os atalhos do Cutling no app Atalhos.",
    "“%@” copiado",
)
T["pt-BR"] = T["pt"]

T["pt-PT"] = (
    "Guardados", "Histórico", "Ainda não há cutlings guardados",
    "Copie algo para o ver aqui", "O histórico da área de transferência está desactivado. Active-o nas Definições.",
    "Spotlight", "Incluir na pesquisa do Spotlight",
    "Torne os seus cutlings pesquisáveis no Spotlight. O conteúdo sensível (cartões de crédito, chaves de API, tokens JWT, frases-semente, chaves privadas) nunca é indexado.",
    "Copiar Cutling", "Copia o conteúdo de um cutling para a área de transferência.",
    "Utilize estas frases com a Siri ou explore todos os atalhos do Cutling na app Atalhos.",
    "«%@» copiado",
)

T["ro"] = (
    "Salvate", "Istoric", "Încă nu există cutling-uri salvate",
    "Copiază ceva pentru a-l vedea aici", "Istoricul clipboard-ului este dezactivat. Activează-l în Setări.",
    "Spotlight", "Include în căutarea Spotlight",
    "Fă cutling-urile tale căutabile din Spotlight. Conținutul sensibil (carduri de credit, chei API, token-uri JWT, fraze seed, chei private) nu este niciodată indexat.",
    "Copiază Cutling-ul", "Copiază conținutul unui cutling în clipboard.",
    "Folosește aceste fraze cu Siri sau răsfoiește toate scurtăturile Cutling în aplicația Scurtături.",
    "„%@” copiat",
)

# ───────── Germanic + Nordic + Baltic ─────────
T["de"] = (
    "Gesichert", "Verlauf", "Noch keine gesicherten Cutlings",
    "Kopiere etwas, um es hier zu sehen", "Der Zwischenablage-Verlauf ist aus. Aktiviere ihn in den Einstellungen.",
    "Spotlight", "In Spotlight-Suche einbeziehen",
    "Mache deine Cutlings über Spotlight durchsuchbar. Sensible Inhalte (Kreditkarten, API-Schlüssel, JWT-Tokens, Seed-Phrasen, private Schlüssel) werden niemals indiziert.",
    "Cutling kopieren", "Kopiert den Inhalt eines Cutlings in die Zwischenablage.",
    "Nutze diese Sätze mit Siri oder durchstöbere alle Cutling-Kurzbefehle in der App Kurzbefehle.",
    "„%@“ kopiert",
)
T["de-DE"] = T["de"]

T["nl"] = (
    "Bewaard", "Geschiedenis", "Nog geen bewaarde cutlings",
    "Kopieer iets om het hier te zien", "Klembordgeschiedenis staat uit. Schakel die in via Instellingen.",
    "Spotlight", "Opnemen in Spotlight-zoekopdracht",
    "Maak je cutlings doorzoekbaar vanuit Spotlight. Gevoelige inhoud (creditcards, API-sleutels, JWT-tokens, seedzinnen, privésleutels) wordt nooit geïndexeerd.",
    "Cutling kopiëren", "Kopieert de inhoud van een cutling naar het klembord.",
    "Gebruik deze zinnen met Siri of blader door alle Cutling-opdrachten in de app Opdrachten.",
    "‘%@’ gekopieerd",
)
T["nl-NL"] = T["nl"]

T["sv"] = (
    "Sparade", "Historik", "Inga sparade cutlings ännu",
    "Kopiera något för att se det här", "Urklippshistoriken är av. Aktivera den i Inställningar.",
    "Spotlight", "Inkludera i Spotlight-sökning",
    "Gör dina cutlings sökbara från Spotlight. Känsligt innehåll (kreditkort, API-nycklar, JWT-tokens, seed-fraser, privata nycklar) indexeras aldrig.",
    "Kopiera Cutling", "Kopierar innehållet i en cutling till urklipp.",
    "Använd dessa fraser med Siri eller bläddra bland alla Cutling-kortkommandon i appen Kortkommandon.",
    "”%@” kopierades",
)

T["da"] = (
    "Arkiverede", "Historik", "Ingen arkiverede cutlings endnu",
    "Kopier noget for at se det her", "Udklipsholderens historik er slået fra. Slå den til i Indstillinger.",
    "Spotlight", "Medtag i Spotlight-søgning",
    "Gør dine cutlings søgbare fra Spotlight. Følsomt indhold (kreditkort, API-nøgler, JWT-tokens, seed-sætninger, private nøgler) indekseres aldrig.",
    "Arkiver Cutling", "Arkiverer indholdet af en cutling i udklipsholderen.",
    "Brug disse sætninger med Siri, eller gennemse alle Cutling-genveje i appen Genveje.",
    "„%@” kopieret",
)

T["nb"] = (
    "Lagrede", "Logg", "Ingen lagrede cutlings ennå",
    "Kopier noe for å se det her", "Utklippstavlens logg er av. Slå den på i Innstillinger.",
    "Spotlight", "Inkluder i Spotlight-søk",
    "Gjør cutlingene dine søkbare fra Spotlight. Sensitivt innhold (kredittkort, API-nøkler, JWT-tokens, seed-fraser, private nøkler) blir aldri indeksert.",
    "Kopier Cutling", "Kopierer innholdet i en cutling til utklippstavlen.",
    "Bruk disse setningene med Siri eller bla gjennom alle Cutling-snarveiene i appen Snarveier.",
    "«%@» kopiert",
)

T["fi"] = (
    "Tallennetut", "Historia", "Ei vielä tallennettuja Cutlingeja",
    "Kopioi jotain nähdäksesi sen täällä", "Leikepöydän historia on poissa päältä. Ota se käyttöön asetuksissa.",
    "Spotlight", "Sisällytä Spotlight-hakuun",
    "Tee Cutlingeistasi haettavia Spotlightista. Arkaluonteista sisältöä (luottokortit, API-avaimet, JWT-tokenit, seed-fraasit, yksityiset avaimet) ei koskaan indeksoida.",
    "Kopioi Cutling", "Kopioi Cutlingin sisällön leikepöydälle.",
    "Käytä näitä lauseita Sirin kanssa tai selaa kaikkia Cutlingin pikakomentoja Pikakomennot-apissa.",
    "”%@” kopioitu",
)

T["et"] = (
    "Salvestatud", "Ajalugu", "Veel pole salvestatud Cutlinge",
    "Kopeeri midagi, et seda siin näha", "Lõikelaua ajalugu on välja lülitatud. Lülita see sätetes sisse.",
    "Spotlight", "Lisa Spotlighti otsingusse",
    "Tee oma Cutlingid Spotlightist otsitavaks. Tundlikku sisu (krediitkaardid, API-võtmed, JWT-žetoonid, algfraasid, privaatvõtmed) ei indekseerita kunagi.",
    "Kopeeri Cutling", "Kopeerib Cutlingu sisu lõikelauale.",
    "Kasuta neid fraase Siriga või sirvi kõiki Cutlingu otseteid rakenduses Otseteed.",
    "„%@“ kopeeritud",
)

T["lt"] = (
    "Įrašyti", "Istorija", "Dar nėra įrašytų cutling‘ų",
    "Ką nors nukopijuok, kad pamatytum čia", "Iškarpinės istorija išjungta. Įjunk ją Nustatymuose.",
    "Spotlight", "Įtraukti į Spotlight paiešką",
    "Padaryk savo cutling‘us paieškomus per Spotlight. Slapta informacija (kredito kortelės, API raktai, JWT žetonai, sėklos frazės, privatūs raktai) niekada nėra indeksuojama.",
    "Kopijuoti Cutling", "Nukopijuoja cutlingo turinį į iškarpinę.",
    "Naudok šias frazes su Siri arba naršyk visus Cutling sparčiuosius mygtukus programėlėje Spartieji mygtukai.",
    "„%@“ nukopijuota",
)

T["lv"] = (
    "Saglabātie", "Vēsture", "Vēl nav saglabātu cutling vienību",
    "Nokopē kaut ko, lai redzētu šeit", "Starpliktuves vēsture ir izslēgta. Ieslēdz to Iestatījumos.",
    "Spotlight", "Iekļaut Spotlight meklēšanā",
    "Padari savas cutling vienības meklējamas no Spotlight. Sensitīvs saturs (kredītkartes, API atslēgas, JWT marķieri, sākotnējās frāzes, privātās atslēgas) nekad netiek indeksēts.",
    "Kopēt Cutling", "Iekopē cutling vienības saturu starpliktuvē.",
    "Lieto šīs frāzes ar Siri vai pārlūko visas Cutling īsceļas lietotnē Īsceļas.",
    "„%@“ nokopēts",
)

# ───────── Slavic + Greek + Hungarian + Turkish ─────────
T["ru"] = (
    "Сохранённые", "История", "Сохранённых Катлингов пока нет",
    "Скопируй что-нибудь, чтобы увидеть здесь", "История буфера обмена выключена. Включи её в Настройках.",
    "Spotlight", "Включить в поиск Spotlight",
    "Сделай свои Катлинги доступными для поиска через Spotlight. Конфиденциальное содержимое (кредитные карты, API-ключи, JWT-токены, сид-фразы, приватные ключи) никогда не индексируется.",
    "Скопировать Катлинг", "Копирует содержимое Катлинга в буфер обмена.",
    "Используй эти фразы с Siri или просматривай все команды Катлинга в приложении Команды.",
    "Скопировано «%@»",
)

T["uk"] = (
    "Збережені", "Історія", "Збережених Катлінгів ще немає",
    "Скопіюй щось, щоб побачити тут", "Історію буфера обміну вимкнено. Увімкни її в Налаштуваннях.",
    "Spotlight", "Включити в пошук Spotlight",
    "Зроби свої Катлінги доступними для пошуку через Spotlight. Конфіденційний вміст (кредитні картки, ключі API, JWT-токени, сід-фрази, приватні ключі) ніколи не індексується.",
    "Скопіювати Катлінг", "Копіює вміст Катлінга в буфер обміну.",
    "Використовуй ці фрази з Siri або переглядай усі команди Катлінга в програмі Команди.",
    "Скопійовано «%@»",
)

T["pl"] = (
    "Zapisane", "Historia", "Jeszcze nie ma zapisanych Cutlingów",
    "Skopiuj coś, by to tu zobaczyć", "Historia schowka jest wyłączona. Włącz ją w Ustawieniach.",
    "Spotlight", "Włącz do wyszukiwania Spotlight",
    "Spraw, by twoje Cutlingi można było wyszukiwać w Spotlight. Wrażliwa zawartość (karty kredytowe, klucze API, tokeny JWT, frazy seed, klucze prywatne) nigdy nie jest indeksowana.",
    "Skopiuj Cutling", "Kopiuje zawartość Cutlinga do schowka.",
    "Użyj tych fraz z Siri lub przeglądaj wszystkie skróty Cutlinga w aplikacji Skróty.",
    "Skopiowano „%@”",
)

T["cs"] = (
    "Uložené", "Historie", "Zatím žádné uložené Cutlingy",
    "Něco zkopíruj, abys to zde viděl", "Historie schránky je vypnutá. Zapni ji v Nastavení.",
    "Spotlight", "Zahrnout do vyhledávání Spotlight",
    "Umožni vyhledávání svých Cutlingů přes Spotlight. Citlivý obsah (platební karty, API klíče, JWT tokeny, seed fráze, privátní klíče) se nikdy neindexuje.",
    "Zkopírovat Cutling", "Kopíruje obsah Cutlingu do schránky.",
    "Použij tyto fráze se Siri nebo procházej všechny zkratky Cutlingu v aplikaci Zkratky.",
    "„%@“ zkopírováno",
)

T["sk"] = (
    "Uložené", "História", "Zatiaľ žiadne uložené Cutlingy",
    "Niečo skopíruj, aby si to tu videl", "História schránky je vypnutá. Zapni ju v Nastaveniach.",
    "Spotlight", "Zahrnúť do vyhľadávania Spotlight",
    "Umožni vyhľadávanie svojich Cutlingov cez Spotlight. Citlivý obsah (platobné karty, API kľúče, JWT tokeny, seed frázy, súkromné kľúče) sa nikdy neindexuje.",
    "Skopírovať Cutling", "Skopíruje obsah Cutlingu do schránky.",
    "Použi tieto frázy so Siri alebo prechádzaj všetky skratky Cutlingu v aplikácii Skratky.",
    "„%@“ skopírované",
)

T["sl"] = (
    "Shranjeni", "Zgodovina", "Še ni shranjenih Cutlingov",
    "Kopiraj nekaj, da boš to videl tukaj", "Zgodovina odložišča je izklopljena. Vklopi jo v Nastavitvah.",
    "Spotlight", "Vključi v iskanje Spotlight",
    "Naredi svoje Cutlinge iskljive iz Spotlighta. Občutljiva vsebina (kreditne kartice, ključi API, žetoni JWT, semenske fraze, zasebni ključi) se nikoli ne indeksira.",
    "Kopiraj Cutling", "Kopira vsebino Cutlinga v odložišče.",
    "Uporabi te fraze s Siri ali prebrskaj vse bližnjice Cutlinga v aplikaciji Bližnjice.",
    "Kopirano „%@“",
)
T["sl-SI"] = T["sl"]

T["hr"] = (
    "Spremljeni", "Povijest", "Još nema spremljenih Cutlinga",
    "Kopiraj nešto da to vidiš ovdje", "Povijest međuspremnika je isključena. Uključi je u Postavkama.",
    "Spotlight", "Uključi u Spotlight pretraživanje",
    "Učini svoje Cutlinge pretraživima iz Spotlighta. Osjetljiv sadržaj (kreditne kartice, API ključevi, JWT tokeni, seed fraze, privatni ključevi) nikad se ne indeksira.",
    "Kopiraj Cutling", "Kopira sadržaj Cutlinga u međuspremnik.",
    "Koristi ove fraze sa Siri ili pregledaj sve prečace Cutlinga u aplikaciji Prečaci.",
    "„%@” kopirano",
)

T["sr"] = (
    "Сачувани", "Историја", "Још нема сачуваних Катлинга",
    "Копирај нешто да то видиш овде", "Историја привремене меморије је искључена. Укључи је у Подешавањима.",
    "Spotlight", "Укључи у Spotlight претрагу",
    "Учини своје Катлинге претраживим из Spotlight-а. Осетљив садржај (кредитне картице, API кључеви, JWT токени, seed фразе, приватни кључеви) се никада не индексира.",
    "Копирај Катлинг", "Копира садржај Катлинга у привремену меморију.",
    "Користи ове фразе са Siri или прегледај све пречице Катлинга у апликацији Пречице.",
    "„%@” копирано",
)

T["bg"] = (
    "Запазени", "История", "Все още няма запазени Кътлинги",
    "Копирай нещо, за да го видиш тук", "Историята на клипборда е изключена. Включи я в Настройките.",
    "Spotlight", "Включи в търсенето на Spotlight",
    "Направи Кътлингите си търсими от Spotlight. Чувствително съдържание (кредитни карти, API ключове, JWT токени, seed фрази, частни ключове) никога не се индексира.",
    "Копирай Кътлинг", "Копира съдържанието на Кътлинг в клипборда.",
    "Използвай тези фрази със Siri или разгледай всички преки пътища на Кътлинг в апликацията Преки пътища.",
    "„%@“ копирано",
)

T["el"] = (
    "Αποθηκευμένα", "Ιστορικό", "Δεν υπάρχουν αποθηκευμένα Cutling ακόμα",
    "Αντίγραψε κάτι για να εμφανιστεί εδώ", "Το ιστορικό προχείρου είναι απενεργοποιημένο. Ενεργοποίησέ το στις Ρυθμίσεις.",
    "Spotlight", "Συμπερίληψη στην αναζήτηση Spotlight",
    "Κάνε τα Cutling σου αναζητήσιμα από το Spotlight. Ευαίσθητο περιεχόμενο (πιστωτικές κάρτες, κλειδιά API, διακριτικά JWT, φράσεις seed, ιδιωτικά κλειδιά) δεν ευρετηριάζεται ποτέ.",
    "Αντιγραφή Cutling", "Αντιγράφει το περιεχόμενο ενός cutling στο πρόχειρο.",
    "Χρησιμοποίησε αυτές τις φράσεις με τη Siri ή περιήγησε σε όλες τις συντομεύσεις του Cutling στην εφαρμογή Συντομεύσεις.",
    "Αντιγράφηκε «%@»",
)

T["hu"] = (
    "Mentett", "Előzmények", "Még nincsenek mentett Cutlingok",
    "Másolj valamit, hogy itt láthasd", "A vágólap-előzmények ki vannak kapcsolva. Kapcsold be a Beállításokban.",
    "Spotlight", "Bevétel a Spotlight-keresésbe",
    "Tedd kereshetővé Cutlingjaidat a Spotlightból. Az érzékeny tartalom (bankkártyák, API-kulcsok, JWT-tokenek, seed-kifejezések, privát kulcsok) sosem kerül indexelésre.",
    "Cutling másolása", "A cutling tartalmát a vágólapra másolja.",
    "Használd ezeket a mondatokat a Sirivel, vagy böngészd a Cutling összes parancsikonját a Parancsikonok appban.",
    "„%@” másolva",
)

T["tr"] = (
    "Kaydedildi", "Geçmiş", "Henüz kaydedilmiş Cutling yok",
    "Burada görmek için bir şey kopyala", "Pano geçmişi kapalı. Ayarlar’dan aç.",
    "Spotlight", "Spotlight aramasına dahil et",
    "Cutling’lerini Spotlight’tan aranabilir yap. Hassas içerik (kredi kartları, API anahtarları, JWT belirteçleri, seed ifadeleri, özel anahtarlar) hiçbir zaman dizine eklenmez.",
    "Cutling’i Kopyala", "Bir cutling’in içeriğini panoya kopyalar.",
    "Bu kalıpları Siri ile kullan ya da Kısayollar uygulamasından tüm Cutling kısayollarına göz at.",
    "“%@” kopyalandı",
)

# ───────── East Asian + SE Asian ─────────
T["ja"] = (
    "保存済み", "履歴", "保存されたカットリングはまだありません",
    "何かをコピーするとここに表示されます", "クリップボード履歴がオフです。設定でオンにしてください。",
    "Spotlight", "Spotlight 検索に含める",
    "カットリングを Spotlight から検索できるようにします。機密情報（クレジットカード、API キー、JWT トークン、シードフレーズ、秘密鍵）は決してインデックス化されません。",
    "カットリングをコピー", "カットリングの内容をクリップボードにコピーします。",
    "これらのフレーズを Siri で使うか、ショートカット App ですべての Cutling ショートカットを参照しましょう。",
    "「%@」をコピーしました",
)

T["ko"] = (
    "저장됨", "기록", "아직 저장된 컷링이 없습니다",
    "복사하면 여기에 표시됩니다", "클립보드 기록이 꺼져 있습니다. 설정에서 켜세요.",
    "Spotlight", "Spotlight 검색에 포함",
    "컷링을 Spotlight에서 검색할 수 있게 합니다. 민감한 콘텐츠(신용카드, API 키, JWT 토큰, 시드 문구, 개인 키)는 절대 색인되지 않습니다.",
    "컷링 복사", "컷링의 내용을 클립보드로 복사합니다.",
    "이 문구를 Siri와 함께 사용하거나 단축어 앱에서 모든 Cutling 단축어를 둘러보세요.",
    "“%@”이(가) 복사됨",
)

T["zh-Hans"] = (
    "已存储", "历史", "暂无已存储的剪切片段",
    "复制内容后会显示在这里", "剪贴板历史已关闭。请在设置中开启。",
    "Spotlight", "包含在 Spotlight 搜索中",
    "让你的剪切片段可以从 Spotlight 搜索到。敏感内容（信用卡、API 密钥、JWT 令牌、助记词、私钥）永不被索引。",
    "拷贝剪切片段", "将剪切片段的内容拷贝到剪贴板。",
    "在 Siri 中使用这些短语，或在“快捷指令” App 中浏览所有 Cutling 快捷指令。",
    "已拷贝“%@”",
)

T["zh-Hant"] = (
    "已儲存", "歷史", "尚無已儲存的剪切片段",
    "複製內容後會顯示在這裡", "剪貼板歷史已關閉。請在設定中開啟。",
    "Spotlight", "納入 Spotlight 搜尋",
    "讓你的剪切片段可從 Spotlight 搜尋到。敏感內容（信用卡、API 金鑰、JWT 權杖、助記詞、私鑰）永不被索引。",
    "拷貝剪切片段", "將剪切片段的內容拷貝到剪貼板。",
    "用這些片語搭配 Siri，或在「捷徑」App 中瀏覽所有 Cutling 捷徑。",
    "已拷貝「%@」",
)

T["vi"] = (
    "Đã lưu", "Lịch sử", "Chưa có cutling nào được lưu",
    "Sao chép gì đó để thấy ở đây", "Lịch sử khay nhớ tạm đã tắt. Bật nó trong Cài đặt.",
    "Spotlight", "Đưa vào tìm kiếm Spotlight",
    "Cho phép tìm cutling của bạn từ Spotlight. Nội dung nhạy cảm (thẻ tín dụng, khoá API, token JWT, cụm từ khoá khôi phục, khoá riêng) không bao giờ bị lập chỉ mục.",
    "Sao chép Cutling", "Sao chép nội dung của một cutling vào khay nhớ tạm.",
    "Dùng các cụm từ này với Siri hoặc duyệt mọi phím tắt Cutling trong ứng dụng Phím tắt.",
    "Đã sao chép “%@”",
)

T["th"] = (
    "บันทึกแล้ว", "ประวัติ", "ยังไม่มีคัตลิงที่บันทึก",
    "คัดลอกบางอย่างเพื่อให้แสดงที่นี่", "ประวัติคลิปบอร์ดปิดอยู่ เปิดในการตั้งค่า",
    "Spotlight", "รวมไว้ในการค้นหา Spotlight",
    "ทำให้คัตลิงของคุณค้นหาได้จาก Spotlight เนื้อหาที่ละเอียดอ่อน (บัตรเครดิต คีย์ API โทเค็น JWT วลีเริ่มต้น คีย์ส่วนตัว) จะไม่ถูกจัดทำดัชนีเลย",
    "คัดลอกคัตลิง", "คัดลอกเนื้อหาของคัตลิงไปยังคลิปบอร์ด",
    "ใช้วลีเหล่านี้กับ Siri หรือเรียกดูคำสั่งลัด Cutling ทั้งหมดในแอปคำสั่งลัด",
    "คัดลอก “%@” แล้ว",
)

T["id"] = (
    "Tersimpan", "Riwayat", "Belum ada cutling tersimpan",
    "Salin sesuatu untuk melihatnya di sini", "Riwayat papan klip nonaktif. Aktifkan di Pengaturan.",
    "Spotlight", "Sertakan dalam pencarian Spotlight",
    "Buat cutling Anda dapat dicari dari Spotlight. Konten sensitif (kartu kredit, kunci API, token JWT, frasa benih, kunci privat) tidak pernah diindeks.",
    "Salin Cutling", "Menyalin konten cutling ke papan klip.",
    "Gunakan frasa ini dengan Siri atau jelajahi semua pintasan Cutling di aplikasi Pintasan.",
    "“%@” disalin",
)

T["ms"] = (
    "Disimpan", "Sejarah", "Tiada cutling disimpan lagi",
    "Salin sesuatu untuk melihatnya di sini", "Sejarah papan keratan dimatikan. Hidupkannya dalam Tetapan.",
    "Spotlight", "Sertakan dalam carian Spotlight",
    "Jadikan cutling anda boleh dicari dari Spotlight. Kandungan sensitif (kad kredit, kunci API, token JWT, frasa benih, kunci peribadi) tidak pernah diindeks.",
    "Salin Cutling", "Menyalin kandungan cutling ke papan keratan.",
    "Gunakan frasa ini dengan Siri atau lihat semua pintasan Cutling dalam aplikasi Pintasan.",
    "“%@” disalin",
)

T["fil"] = (
    "Nai-save", "Kasaysayan", "Wala pang naka-save na cutling",
    "Mag-copy ng kahit ano para makita rito", "Naka-off ang kasaysayan ng clipboard. I-on sa Settings.",
    "Spotlight", "Isama sa paghahanap sa Spotlight",
    "Gawing mahahanap ang iyong mga cutling sa Spotlight. Ang sensitibong nilalaman (credit cards, API keys, JWT tokens, seed phrases, private keys) ay hindi kailanman ini-index.",
    "Kopyahin ang Cutling", "Kinokopya ang nilalaman ng cutling sa clipboard.",
    "Gamitin ang mga pariralang ito sa Siri o tingnan ang lahat ng Cutling shortcut sa Shortcuts app.",
    "Na-copy ang “%@”",
)

# ───────── Indian languages ─────────
T["hi"] = (
    "सहेजे गए", "इतिहास", "अभी तक कोई सहेजा गया कटलिंग नहीं",
    "यहाँ देखने के लिए कुछ कॉपी करें", "क्लिपबोर्ड इतिहास बंद है। इसे सेटिंग्स में चालू करें।",
    "Spotlight", "Spotlight खोज में शामिल करें",
    "अपने कटलिंग को Spotlight से खोजने योग्य बनाएँ। संवेदनशील सामग्री (क्रेडिट कार्ड, API कुंजियाँ, JWT टोकन, बीज वाक्यांश, निजी कुंजियाँ) कभी अनुक्रमित नहीं होती।",
    "कटलिंग कॉपी करें", "कटलिंग की सामग्री को क्लिपबोर्ड में कॉपी करता है।",
    "इन वाक्यांशों को Siri के साथ उपयोग करें या Shortcuts ऐप में सभी Cutling शॉर्टकट देखें।",
    "“%@” कॉपी हो गया",
)

T["bn"] = (
    "সংরক্ষিত", "ইতিহাস", "এখনও কোনও সংরক্ষিত কাটলিং নেই",
    "এখানে দেখতে কিছু কপি করুন", "ক্লিপবোর্ড ইতিহাস বন্ধ আছে। সেটিংসে চালু করুন।",
    "Spotlight", "Spotlight অনুসন্ধানে অন্তর্ভুক্ত করুন",
    "আপনার কাটলিংগুলিকে Spotlight থেকে অনুসন্ধানযোগ্য করুন। সংবেদনশীল সামগ্রী (ক্রেডিট কার্ড, API কী, JWT টোকেন, সিড বাক্যাংশ, ব্যক্তিগত কী) কখনই সূচীবদ্ধ হয় না।",
    "কাটলিং কপি করুন", "কাটলিংয়ের সামগ্রী ক্লিপবোর্ডে কপি করে।",
    "এই বাক্যাংশগুলি Siri-র সাথে ব্যবহার করুন বা Shortcuts অ্যাপে সমস্ত Cutling শর্টকাট ব্রাউজ করুন।",
    "“%@” কপি করা হয়েছে",
)
T["bn-BD"] = T["bn"]

T["mr"] = (
    "जतन केलेले", "इतिहास", "अद्याप कोणतेही जतन केलेले कटलिंग नाहीत",
    "येथे पाहण्यासाठी काहीतरी कॉपी करा", "क्लिपबोर्ड इतिहास बंद आहे. सेटिंग्जमध्ये चालू करा.",
    "Spotlight", "Spotlight शोधात समाविष्ट करा",
    "तुमचे कटलिंग Spotlight वरून शोधण्यायोग्य करा. संवेदनशील सामग्री (क्रेडिट कार्ड, API कीज, JWT टोकन्स, सीड वाक्ये, खाजगी कीज) कधीही अनुक्रमित होत नाही.",
    "कटलिंग कॉपी करा", "कटलिंगची सामग्री क्लिपबोर्डवर कॉपी करते.",
    "ही वाक्ये Siri सोबत वापरा किंवा Shortcuts ॲपमध्ये सर्व Cutling शॉर्टकट पाहा.",
    "“%@” कॉपी झाले",
)
T["mr-IN"] = T["mr"]

T["gu"] = (
    "સચવાયેલા", "ઇતિહાસ", "હજુ સુધી કોઈ સચવાયેલા કટલિંગ નથી",
    "અહીં જોવા માટે કંઈક કૉપિ કરો", "ક્લિપબોર્ડ ઇતિહાસ બંધ છે. તેને સેટિંગ્સમાં ચાલુ કરો.",
    "Spotlight", "Spotlight શોધમાં શામેલ કરો",
    "તમારા કટલિંગને Spotlight થી શોધી શકાય તેવા બનાવો. સંવેદનશીલ સામગ્રી (ક્રેડિટ કાર્ડ, API કીઝ, JWT ટોકન્સ, બીજ વાક્યો, ખાનગી કીઝ) ક્યારેય ઇન્ડેક્સ થતી નથી.",
    "કટલિંગ કૉપિ કરો", "કટલિંગની સામગ્રીને ક્લિપબોર્ડ પર કૉપિ કરે છે.",
    "આ વાક્યો Siri સાથે ઉપયોગ કરો અથવા Shortcuts ઍપમાં બધી Cutling શૉર્ટકટ બ્રાઉઝ કરો.",
    "“%@” કૉપિ થયું",
)
T["gu-IN"] = T["gu"]

T["ta"] = (
    "சேமிக்கப்பட்டவை", "வரலாறு", "சேமிக்கப்பட்ட கட்லிங்குகள் இன்னும் இல்லை",
    "இங்கே காண ஏதாவது நகலெடுக்க", "கிளிப்போர்டு வரலாறு முடக்கப்பட்டுள்ளது. அமைப்புகளில் இயக்கவும்.",
    "Spotlight", "Spotlight தேடலில் சேர்",
    "உங்கள் கட்லிங்குகளை Spotlight இலிருந்து தேடக்கூடியவையாக ஆக்குங்கள். உணர்திறன் கொண்ட உள்ளடக்கம் (கிரெடிட் கார்டுகள், API விசைகள், JWT டோக்கன்கள், விதைச் சொற்றொடர்கள், தனிப்பட்ட விசைகள்) ஒருபோதும் சுட்டிடப்படுவதில்லை.",
    "கட்லிங்கை நகலெடு", "கட்லிங்கின் உள்ளடக்கத்தைக் கிளிப்போர்டில் நகலெடுக்கிறது.",
    "இந்தச் சொற்றொடர்களை Siri உடன் பயன்படுத்தவும் அல்லது Shortcuts ஆப்பில் அனைத்து Cutling குறுக்குவழிகளையும் உலாவவும்.",
    "“%@” நகலெடுக்கப்பட்டது",
)
T["ta-IN"] = T["ta"]

T["te"] = (
    "సేవ్ చేసినవి", "చరిత్ర", "ఇంకా సేవ్ చేసిన కట్లింగ్‌లు లేవు",
    "ఇక్కడ చూడడానికి ఏదైనా కాపీ చేయండి", "క్లిప్‌బోర్డ్ చరిత్ర ఆఫ్‌లో ఉంది. సెట్టింగ్‌లలో ఆన్ చేయండి.",
    "Spotlight", "Spotlight శోధనలో చేర్చండి",
    "మీ కట్లింగ్‌లను Spotlight నుండి శోధించదగినవిగా చేయండి. సున్నితమైన కంటెంట్ (క్రెడిట్ కార్డ్‌లు, API కీలు, JWT టోకెన్‌లు, సీడ్ పదబంధాలు, ప్రైవేట్ కీలు) ఎప్పటికీ ఇండెక్స్ చేయబడదు.",
    "కట్లింగ్‌ను కాపీ చేయండి", "కట్లింగ్ యొక్క కంటెంట్‌ను క్లిప్‌బోర్డ్‌కు కాపీ చేస్తుంది.",
    "ఈ పదబంధాలను Siri తో ఉపయోగించండి లేదా Shortcuts యాప్‌లో అన్ని Cutling షార్ట్‌కట్‌లను బ్రౌజ్ చేయండి.",
    "“%@” కాపీ చేయబడింది",
)
T["te-IN"] = T["te"]

T["kn"] = (
    "ಉಳಿಸಲಾಗಿದೆ", "ಇತಿಹಾಸ", "ಇನ್ನೂ ಯಾವುದೇ ಉಳಿಸಲಾದ ಕಟ್ಲಿಂಗ್‌ಗಳಿಲ್ಲ",
    "ಇಲ್ಲಿ ನೋಡಲು ಏನನ್ನಾದರೂ ನಕಲಿಸಿ", "ಕ್ಲಿಪ್‌ಬೋರ್ಡ್ ಇತಿಹಾಸ ಆಫ್ ಆಗಿದೆ. ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಆನ್ ಮಾಡಿ.",
    "Spotlight", "Spotlight ಹುಡುಕಾಟದಲ್ಲಿ ಸೇರಿಸಿ",
    "ನಿಮ್ಮ ಕಟ್ಲಿಂಗ್‌ಗಳನ್ನು Spotlight ನಿಂದ ಹುಡುಕಬಲ್ಲಂತೆ ಮಾಡಿ. ಸೂಕ್ಷ್ಮ ವಿಷಯ (ಕ್ರೆಡಿಟ್ ಕಾರ್ಡ್‌ಗಳು, API ಕೀಲಿಗಳು, JWT ಟೋಕನ್‌ಗಳು, ಬೀಜ ಪದಗುಚ್ಛಗಳು, ಖಾಸಗಿ ಕೀಲಿಗಳು) ಎಂದಿಗೂ ಸೂಚ್ಯಂಕಗೊಳಿಸಲ್ಪಡುವುದಿಲ್ಲ.",
    "ಕಟ್ಲಿಂಗ್ ನಕಲಿಸಿ", "ಕಟ್ಲಿಂಗ್‌ನ ವಿಷಯವನ್ನು ಕ್ಲಿಪ್‌ಬೋರ್ಡ್‌ಗೆ ನಕಲಿಸುತ್ತದೆ.",
    "ಈ ಪದಗುಚ್ಛಗಳನ್ನು Siri ಜೊತೆ ಬಳಸಿ ಅಥವಾ Shortcuts ಆ್ಯಪ್‌ನಲ್ಲಿ ಎಲ್ಲಾ Cutling ಶಾರ್ಟ್‌ಕಟ್‌ಗಳನ್ನು ಬ್ರೌಸ್ ಮಾಡಿ.",
    "“%@” ನಕಲಾಗಿದೆ",
)
T["kn-IN"] = T["kn"]

T["ml"] = (
    "സംരക്ഷിച്ചവ", "ചരിത്രം", "ഇതുവരെ സംരക്ഷിച്ച കട്ട്‌ലിംഗുകൾ ഇല്ല",
    "ഇവിടെ കാണാൻ എന്തെങ്കിലും പകർത്തുക", "ക്ലിപ്പ്ബോർഡ് ചരിത്രം ഓഫാണ്. ക്രമീകരണങ്ങളിൽ ഓണാക്കുക.",
    "Spotlight", "Spotlight തിരയലിൽ ഉൾപ്പെടുത്തുക",
    "നിങ്ങളുടെ കട്ട്‌ലിംഗുകൾ Spotlight ൽ നിന്ന് തിരയാൻ കഴിയുന്നതാക്കുക. സെൻസിറ്റീവ് ഉള്ളടക്കം (ക്രെഡിറ്റ് കാർഡുകൾ, API കീകൾ, JWT ടോക്കണുകൾ, വിത്ത് വാക്യങ്ങൾ, സ്വകാര്യ കീകൾ) ഒരിക്കലും സൂചികപ്പെടുത്തുന്നില്ല.",
    "കട്ട്‌ലിംഗ് പകർത്തുക", "ഒരു കട്ട്‌ലിംഗിന്റെ ഉള്ളടക്കം ക്ലിപ്പ്ബോർഡിലേക്ക് പകർത്തുന്നു.",
    "ഈ വാക്യങ്ങൾ Siri യുമായി ഉപയോഗിക്കുക അല്ലെങ്കിൽ Shortcuts ആപ്പിൽ എല്ലാ Cutling കുറുക്കുവഴികളും ബ്രൗസ് ചെയ്യുക.",
    "“%@” പകർത്തി",
)
T["ml-IN"] = T["ml"]

T["or"] = (
    "ସଞ୍ଚୟ ହୋଇଥିବା", "ଇତିହାସ", "ଏପର୍ଯ୍ୟନ୍ତ କୌଣସି ସଞ୍ଚୟ ହୋଇଥିବା କଟ୍‌ଲିଂ ନାହିଁ",
    "ଏଠାରେ ଦେଖିବାକୁ କିଛି କପି କରନ୍ତୁ", "କ୍ଲିପବୋର୍ଡ ଇତିହାସ ବନ୍ଦ ଅଛି। ସେଟିଂସରେ ଚାଲୁ କରନ୍ତୁ।",
    "Spotlight", "Spotlight ସନ୍ଧାନରେ ଅନ୍ତର୍ଭୁକ୍ତ କରନ୍ତୁ",
    "ଆପଣଙ୍କର କଟ୍‌ଲିଂଗୁଡ଼ିକୁ Spotlight ରୁ ସନ୍ଧାନଯୋଗ୍ୟ କରନ୍ତୁ। ସମ୍ବେଦନଶୀଳ ବିଷୟବସ୍ତୁ (କ୍ରେଡିଟ କାର୍ଡ, API ଚାବି, JWT ଟୋକନ, ସିଡ ବାକ୍ୟ, ବ୍ୟକ୍ତିଗତ ଚାବି) କେବେ ସୂଚୀଭୁକ୍ତ ହୁଏ ନାହିଁ।",
    "କଟ୍‌ଲିଂ କପି କରନ୍ତୁ", "ଏକ କଟ୍‌ଲିଂର ବିଷୟବସ୍ତୁକୁ କ୍ଲିପବୋର୍ଡରେ କପି କରେ।",
    "ଏହି ବାକ୍ୟଗୁଡ଼ିକୁ Siri ସହିତ ବ୍ୟବହାର କରନ୍ତୁ କିମ୍ବା Shortcuts ଆପରେ ସମସ୍ତ Cutling ସର୍ଟକଟ ଖୋଜନ୍ତୁ।",
    "“%@” କପି ହୋଇଛି",
)
T["or-IN"] = T["or"]

T["pa"] = (
    "ਸੰਭਾਲੇ ਗਏ", "ਇਤਿਹਾਸ", "ਅਜੇ ਕੋਈ ਸੰਭਾਲੇ ਗਏ ਕਟਲਿੰਗ ਨਹੀਂ",
    "ਇੱਥੇ ਵੇਖਣ ਲਈ ਕੁਝ ਕਾਪੀ ਕਰੋ", "ਕਲਿੱਪਬੋਰਡ ਇਤਿਹਾਸ ਬੰਦ ਹੈ। ਇਸਨੂੰ ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਚਾਲੂ ਕਰੋ।",
    "Spotlight", "Spotlight ਖੋਜ ਵਿੱਚ ਸ਼ਾਮਲ ਕਰੋ",
    "ਆਪਣੇ ਕਟਲਿੰਗ ਨੂੰ Spotlight ਤੋਂ ਖੋਜਣਯੋਗ ਬਣਾਓ। ਸੰਵੇਦਨਸ਼ੀਲ ਸਮੱਗਰੀ (ਕ੍ਰੈਡਿਟ ਕਾਰਡ, API ਕੁੰਜੀਆਂ, JWT ਟੋਕਨ, ਬੀਜ ਸ਼ਬਦ, ਨਿੱਜੀ ਕੁੰਜੀਆਂ) ਕਦੇ ਵੀ ਇੰਡੈਕਸ ਨਹੀਂ ਹੁੰਦੀ।",
    "ਕਟਲਿੰਗ ਕਾਪੀ ਕਰੋ", "ਕਟਲਿੰਗ ਦੀ ਸਮੱਗਰੀ ਨੂੰ ਕਲਿੱਪਬੋਰਡ ਵਿੱਚ ਕਾਪੀ ਕਰਦਾ ਹੈ।",
    "ਇਹ ਵਾਕਾਂਸ਼ Siri ਨਾਲ ਵਰਤੋ ਜਾਂ Shortcuts ਐਪ ਵਿੱਚ ਸਾਰੇ Cutling ਸ਼ਾਰਟਕੱਟ ਬ੍ਰਾਊਜ਼ ਕਰੋ।",
    "“%@” ਕਾਪੀ ਕੀਤਾ ਗਿਆ",
)
T["pa-IN"] = T["pa"]

# ───────── Semitic + Iranian + Urdu + Swahili ─────────
T["ar"] = (
    "محفوظات", "السجل", "لا توجد كاتلينج محفوظة بعد",
    "انسخ شيئًا لتراه هنا", "سجل الحافظة متوقف. شغّله في الإعدادات.",
    "Spotlight", "تضمين في بحث Spotlight",
    "اجعل كاتلينج الخاصة بك قابلة للبحث من Spotlight. المحتوى الحساس (بطاقات الائتمان، مفاتيح API، رموز JWT، عبارات seed، المفاتيح الخاصة) لا تتم فهرسته أبدًا.",
    "نسخ كاتلينج", "ينسخ محتوى الكاتلينج إلى الحافظة.",
    "استخدم هذه العبارات مع Siri أو تصفح كل اختصارات Cutling في تطبيق الاختصارات.",
    "تم نسخ «%@»",
)
T["ar-SA"] = T["ar"]

T["he"] = (
    "שמורים", "היסטוריה", "אין עדיין קאטלינגים שמורים",
    "העתק משהו כדי לראותו כאן", "היסטוריית הלוח כבויה. הפעל אותה בהגדרות.",
    "Spotlight", "כלול בחיפוש Spotlight",
    "הפוך את הקאטלינגים שלך לניתנים לחיפוש מ-Spotlight. תוכן רגיש (כרטיסי אשראי, מפתחות API, אסימוני JWT, ביטויי seed, מפתחות פרטיים) לעולם לא נכלל באינדקס.",
    "העתק קאטלינג", "מעתיק את תוכן הקאטלינג ללוח.",
    "השתמש בביטויים אלה עם Siri או עיין בכל הקיצורים של Cutling באפליקציית הקיצורים.",
    "“%@” הועתק",
)

T["fa"] = (
    "ذخیره‌شده‌ها", "تاریخچه", "هنوز هیچ کاتلینگ ذخیره‌شده‌ای وجود ندارد",
    "چیزی کپی کن تا اینجا ببینی", "تاریخچهٔ کلیپ‌بورد خاموش است. آن را در تنظیمات روشن کن.",
    "Spotlight", "گنجاندن در جستجوی Spotlight",
    "کاتلینگ‌های خود را از طریق Spotlight قابل جستجو کن. محتوای حساس (کارت‌های اعتباری، کلیدهای API، توکن‌های JWT، عبارت‌های seed، کلیدهای خصوصی) هرگز فهرست‌بندی نمی‌شود.",
    "کپی کاتلینگ", "محتوای کاتلینگ را در کلیپ‌بورد کپی می‌کند.",
    "این عبارات را با Siri استفاده کن یا همهٔ میانبرهای Cutling را در اپ میانبرها مرور کن.",
    "«%@» کپی شد",
)

T["ur"] = (
    "محفوظ", "تاریخ", "ابھی تک کوئی محفوظ کٹلنگ نہیں",
    "یہاں دیکھنے کے لیے کچھ کاپی کریں", "کلپ بورڈ تاریخ بند ہے۔ اسے ترتیبات میں آن کریں۔",
    "Spotlight", "Spotlight تلاش میں شامل کریں",
    "اپنے کٹلنگ کو Spotlight سے قابل تلاش بنائیں۔ حساس مواد (کریڈٹ کارڈ، API کلیدیں، JWT ٹوکن، سیڈ جملے، نجی کلیدیں) کبھی انڈیکس نہیں ہوتا۔",
    "کٹلنگ کاپی کریں", "کٹلنگ کے مواد کو کلپ بورڈ میں کاپی کرتا ہے۔",
    "ان جملوں کو Siri کے ساتھ استعمال کریں یا Shortcuts ایپ میں تمام Cutling شارٹ کٹس دیکھیں۔",
    "“%@” کاپی ہو گیا",
)
T["ur-PK"] = T["ur"]

T["sw"] = (
    "Zilizohifadhiwa", "Historia", "Bado hakuna Cutling zilizohifadhiwa",
    "Nakili kitu ili kuona hapa", "Historia ya ubao wa kunakili imezimwa. Iwashe katika Mipangilio.",
    "Spotlight", "Jumuisha katika utafutaji wa Spotlight",
    "Fanya Cutling zako zitafutwa kupitia Spotlight. Maudhui nyeti (kadi za mkopo, funguo za API, tokeni za JWT, vifungu vya seed, funguo za faragha) hayaorodheshwi kamwe.",
    "Nakili Cutling", "Hunakili maudhui ya Cutling kwenye ubao wa kunakili.",
    "Tumia misemo hii pamoja na Siri au vinjari njia za mkato za Cutling zote katika programu ya Njia za Mkato.",
    "“%@” imenakiliwa",
)


def existing_keys(path):
    if not path.exists():
        return set()
    text = path.read_text(encoding="utf-8")
    pattern = re.compile(r'^"((?:[^"\\]|\\.)*)"\s*=', re.MULTILINE)
    return {m.group(1).replace('\\"', '"').replace('\\\\', '\\') for m in pattern.finditer(text)}


def escape(s):
    return s.replace("\\", "\\\\").replace('"', '\\"')


def apply_locale(locale, values):
    target = CUTLING_DIR / f"{locale}.lproj" / "Localizable.strings"
    if not target.exists():
        return "missing dir"
    present = existing_keys(target)
    pairs = [(k, v) for k, v in zip(KEYS, values) if k not in present]
    if not pairs:
        return "skip"
    lines = ["", "/* MARK: - Newly added keys */"]
    for k, v in pairs:
        lines.append(f'"{escape(k)}" = "{escape(v)}";')
    body = "\n".join(lines) + "\n"
    with target.open("a", encoding="utf-8") as f:
        f.write(("\n" if target.stat().st_size > 0 else "") + body)
    return f"+{len(pairs)}"


def main():
    skipped = []
    for lproj in sorted(CUTLING_DIR.glob("*.lproj")):
        locale = lproj.name.replace(".lproj", "")
        if locale.startswith("en"):
            continue
        if locale not in T:
            skipped.append(locale)
            continue
        result = apply_locale(locale, T[locale])
        print(f"  {locale}: {result}")
    if skipped:
        print(f"\nNo translation for: {', '.join(skipped)}")


if __name__ == "__main__":
    main()
