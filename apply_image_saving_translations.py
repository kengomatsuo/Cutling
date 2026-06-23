#!/usr/bin/env python3
"""
Append hand-crafted translations for the new "Image Saving" Localizable.strings
keys to every Cutling/*.lproj/Localizable.strings file. Idempotent: skips keys
that are already present.

All translations are written here as hardcoded literals — no machine translator.
"""

import re
from pathlib import Path

REPO_ROOT = Path(__file__).parent
CUTLING_DIR = REPO_ROOT / "Cutling"

# 12 source English keys, in canonical order.
KEYS = [
    "Save as File…",
    "Image Saving",
    "When saving images",
    "Ask each time",
    "Save to folder",
    "Folder",
    "Change Folder…",
    "Choose how the “Save as File” action works for image cutlings. With “Save to folder”, images go straight into the folder you pick with a unique filename, no prompt.",
    "Choose",
    "Choose Image Folder",
    "Pick a folder where Cutling will save image cutlings.",
    "Preview",
]

# Per-locale translations. Each entry is a 12-tuple in KEYS order.
# Curly quotes (“ ”) are used for the S8 footer where shown.
TRANSLATIONS = {}

def _en():
    return (
        "Save as File…",
        "Image Saving",
        "When saving images",
        "Ask each time",
        "Save to folder",
        "Folder",
        "Change Folder…",
        "Choose how the “Save as File” action works for image cutlings. With “Save to folder”, images go straight into the folder you pick with a unique filename, no prompt.",
        "Choose",
        "Choose Image Folder",
        "Pick a folder where Cutling will save image cutlings.",
        "Preview",
    )

TRANSLATIONS["en"] = _en()
TRANSLATIONS["en-AU"] = _en()
TRANSLATIONS["en-CA"] = _en()
TRANSLATIONS["en-GB"] = _en()
TRANSLATIONS["en-IN"] = _en()

# ───────── Romance ─────────

TRANSLATIONS["es"] = (
    "Guardar como archivo…",
    "Guardado de imágenes",
    "Al guardar imágenes",
    "Preguntar siempre",
    "Guardar en una carpeta",
    "Carpeta",
    "Cambiar carpeta…",
    "Elige cómo funciona la acción “Guardar como archivo” para los cutlings de imagen. Con “Guardar en una carpeta”, las imágenes van directamente a la carpeta que elijas con un nombre de archivo único, sin preguntar.",
    "Elegir",
    "Elegir carpeta de imágenes",
    "Elige una carpeta donde Cutling guardará los cutlings de imagen.",
    "Vista previa",
)
TRANSLATIONS["es-ES"] = TRANSLATIONS["es"]
TRANSLATIONS["es-MX"] = TRANSLATIONS["es"]

TRANSLATIONS["fr"] = (
    "Enregistrer comme fichier…",
    "Enregistrement des images",
    "Lors de l’enregistrement des images",
    "Demander à chaque fois",
    "Enregistrer dans un dossier",
    "Dossier",
    "Changer de dossier…",
    "Choisissez le fonctionnement de l’action “Enregistrer comme fichier” pour les cutlings image. Avec “Enregistrer dans un dossier”, les images sont placées directement dans le dossier choisi sous un nom de fichier unique, sans demande.",
    "Choisir",
    "Choisir un dossier d’images",
    "Choisissez un dossier où Cutling enregistrera les cutlings image.",
    "Aperçu",
)
TRANSLATIONS["fr-CA"] = TRANSLATIONS["fr"]
TRANSLATIONS["fr-FR"] = TRANSLATIONS["fr"]

TRANSLATIONS["it"] = (
    "Salva come file…",
    "Salvataggio delle immagini",
    "Quando salvi le immagini",
    "Chiedi ogni volta",
    "Salva in una cartella",
    "Cartella",
    "Cambia cartella…",
    "Scegli come funziona l’azione “Salva come file” per i cutling immagine. Con “Salva in una cartella”, le immagini vengono salvate direttamente nella cartella scelta con un nome univoco, senza richieste.",
    "Scegli",
    "Scegli la cartella delle immagini",
    "Scegli una cartella in cui Cutling salverà i cutling immagine.",
    "Anteprima",
)

TRANSLATIONS["pt"] = (
    "Salvar como arquivo…",
    "Salvamento de imagens",
    "Ao salvar imagens",
    "Perguntar sempre",
    "Salvar em uma pasta",
    "Pasta",
    "Alterar pasta…",
    "Escolha como a ação “Salvar como arquivo” funciona para os cutlings de imagem. Com “Salvar em uma pasta”, as imagens vão direto para a pasta escolhida com um nome de arquivo único, sem aviso.",
    "Escolher",
    "Escolher pasta de imagens",
    "Escolha uma pasta onde o Cutling salvará os cutlings de imagem.",
    "Pré-visualização",
)
TRANSLATIONS["pt-BR"] = TRANSLATIONS["pt"]

TRANSLATIONS["pt-PT"] = (
    "Guardar como ficheiro…",
    "Guardar imagens",
    "Ao guardar imagens",
    "Perguntar sempre",
    "Guardar numa pasta",
    "Pasta",
    "Alterar pasta…",
    "Escolha como a ação “Guardar como ficheiro” funciona para os cutlings de imagem. Com “Guardar numa pasta”, as imagens são guardadas directamente na pasta escolhida com um nome de ficheiro único, sem perguntar.",
    "Escolher",
    "Escolher pasta de imagens",
    "Escolha uma pasta onde o Cutling guardará os cutlings de imagem.",
    "Pré-visualização",
)

TRANSLATIONS["ca"] = (
    "Desar com a fitxer…",
    "Desament d’imatges",
    "En desar imatges",
    "Preguntar sempre",
    "Desar a una carpeta",
    "Carpeta",
    "Canviar carpeta…",
    "Tria com funciona l’acció “Desar com a fitxer” per als cutlings d’imatge. Amb “Desar a una carpeta”, les imatges van directament a la carpeta triada amb un nom de fitxer únic, sense preguntar.",
    "Triar",
    "Triar carpeta d’imatges",
    "Tria una carpeta on Cutling desarà els cutlings d’imatge.",
    "Visualització prèvia",
)

TRANSLATIONS["ro"] = (
    "Salvează ca fișier…",
    "Salvare imagini",
    "La salvarea imaginilor",
    "Întreabă de fiecare dată",
    "Salvează într-un dosar",
    "Dosar",
    "Schimbă dosarul…",
    "Alege cum funcționează acțiunea “Salvează ca fișier” pentru cutling-urile imagine. Cu “Salvează într-un dosar”, imaginile merg direct în dosarul ales cu un nume de fișier unic, fără întrebări.",
    "Alege",
    "Alege dosarul de imagini",
    "Alege un dosar în care Cutling va salva cutling-urile imagine.",
    "Previzualizare",
)

# ───────── Germanic ─────────

TRANSLATIONS["de"] = (
    "Als Datei sichern…",
    "Bildsicherung",
    "Beim Sichern von Bildern",
    "Jedes Mal fragen",
    "In Ordner sichern",
    "Ordner",
    "Ordner ändern…",
    "Lege fest, wie die Aktion „Als Datei sichern“ für Bild-Cutlings funktioniert. Mit „In Ordner sichern“ werden Bilder direkt im gewählten Ordner mit einem eindeutigen Dateinamen abgelegt, ohne Nachfrage.",
    "Auswählen",
    "Bildordner auswählen",
    "Wähle einen Ordner, in dem Cutling Bild-Cutlings sichert.",
    "Vorschau",
)
TRANSLATIONS["de-DE"] = TRANSLATIONS["de"]

TRANSLATIONS["nl"] = (
    "Bewaar als bestand…",
    "Afbeeldingen bewaren",
    "Bij het bewaren van afbeeldingen",
    "Elke keer vragen",
    "Bewaar in een map",
    "Map",
    "Wijzig map…",
    "Kies hoe de actie “Bewaar als bestand” werkt voor afbeelding-cutlings. Met “Bewaar in een map” worden afbeeldingen rechtstreeks in de gekozen map opgeslagen met een unieke bestandsnaam, zonder vraag.",
    "Kies",
    "Kies afbeeldingenmap",
    "Kies een map waar Cutling afbeelding-cutlings bewaart.",
    "Voorvertoning",
)
TRANSLATIONS["nl-NL"] = TRANSLATIONS["nl"]

TRANSLATIONS["sv"] = (
    "Spara som fil…",
    "Bildsparande",
    "När bilder sparas",
    "Fråga varje gång",
    "Spara i mapp",
    "Mapp",
    "Byt mapp…",
    "Välj hur åtgärden ”Spara som fil” fungerar för bild-cutlings. Med ”Spara i mapp” sparas bilder direkt i den valda mappen med ett unikt filnamn, utan fråga.",
    "Välj",
    "Välj bildmapp",
    "Välj en mapp där Cutling sparar bild-cutlings.",
    "Förhandsvisning",
)

TRANSLATIONS["da"] = (
    "Arkiver som fil…",
    "Billedarkivering",
    "Når der arkiveres billeder",
    "Spørg hver gang",
    "Arkiver i mappe",
    "Mappe",
    "Skift mappe…",
    "Vælg, hvordan handlingen „Arkiver som fil” fungerer for billed-cutlings. Med „Arkiver i mappe” arkiveres billeder direkte i den valgte mappe med et unikt filnavn, uden at spørge.",
    "Vælg",
    "Vælg billedmappe",
    "Vælg en mappe, hvor Cutling arkiverer billed-cutlings.",
    "Eksempel",
)

TRANSLATIONS["nb"] = (
    "Arkiver som fil…",
    "Bildelagring",
    "Når bilder lagres",
    "Spør hver gang",
    "Lagre i mappe",
    "Mappe",
    "Bytt mappe…",
    "Velg hvordan handlingen «Arkiver som fil» fungerer for bilde-cutlings. Med «Lagre i mappe» lagres bilder direkte i mappen du velger med et unikt filnavn, uten spørsmål.",
    "Velg",
    "Velg bildemappe",
    "Velg en mappe der Cutling skal lagre bilde-cutlings.",
    "Forhåndsvisning",
)

TRANSLATIONS["fi"] = (
    "Tallenna tiedostona…",
    "Kuvien tallennus",
    "Kuvia tallennettaessa",
    "Kysy joka kerta",
    "Tallenna kansioon",
    "Kansio",
    "Vaihda kansio…",
    "Valitse, miten toiminto ”Tallenna tiedostona” toimii kuva-Cutlingeille. Vaihtoehdolla ”Tallenna kansioon” kuvat tallennetaan suoraan valitsemaasi kansioon ainutkertaisella tiedostonimellä, ilman kyselyä.",
    "Valitse",
    "Valitse kuvakansio",
    "Valitse kansio, johon Cutling tallentaa kuva-Cutlingit.",
    "Esikatselu",
)

TRANSLATIONS["et"] = (
    "Salvesta failina…",
    "Piltide salvestamine",
    "Piltide salvestamisel",
    "Küsi iga kord",
    "Salvesta kausta",
    "Kaust",
    "Muuda kausta…",
    "Vali, kuidas tegevus „Salvesta failina” töötab pildi-Cutlingute jaoks. Valikuga „Salvesta kausta” salvestatakse pildid otse sinu valitud kausta unikaalse failinimega, ilma küsimata.",
    "Vali",
    "Vali pildikaust",
    "Vali kaust, kuhu Cutling pildi-Cutlingid salvestab.",
    "Eelvaade",
)

TRANSLATIONS["lt"] = (
    "Įrašyti kaip failą…",
    "Vaizdų įrašymas",
    "Įrašant vaizdus",
    "Klausti kiekvieną kartą",
    "Įrašyti į aplanką",
    "Aplankas",
    "Keisti aplanką…",
    "Pasirink, kaip veikia veiksmas „Įrašyti kaip failą“ vaizdo cutling‘ams. Su „Įrašyti į aplanką“ vaizdai keliauja tiesiai į pasirinktą aplanką su unikaliu failo pavadinimu, be klausimo.",
    "Pasirinkti",
    "Pasirinkti vaizdų aplanką",
    "Pasirink aplanką, kuriame Cutling įrašys vaizdo cutling‘us.",
    "Peržiūra",
)

TRANSLATIONS["lv"] = (
    "Saglabāt kā failu…",
    "Attēlu saglabāšana",
    "Saglabājot attēlus",
    "Vaicāt katru reizi",
    "Saglabāt mapē",
    "Mape",
    "Mainīt mapi…",
    "Izvēlies, kā darbība „Saglabāt kā failu“ darbojas attēlu Cutling vienībām. Ar „Saglabāt mapē“ attēli tiek saglabāti tieši izvēlētajā mapē ar unikālu faila nosaukumu, bez vaicāšanas.",
    "Izvēlēties",
    "Izvēlēties attēlu mapi",
    "Izvēlies mapi, kurā Cutling saglabās attēlu Cutling vienības.",
    "Priekšskatījums",
)

# ───────── Slavic ─────────

TRANSLATIONS["ru"] = (
    "Сохранить как файл…",
    "Сохранение изображений",
    "При сохранении изображений",
    "Спрашивать каждый раз",
    "Сохранять в папку",
    "Папка",
    "Изменить папку…",
    "Выберите, как работает действие «Сохранить как файл» для Катлингов с изображениями. С «Сохранять в папку» изображения попадают прямо в выбранную папку с уникальным именем файла, без запросов.",
    "Выбрать",
    "Выбор папки для изображений",
    "Выберите папку, в которую Катлинг будет сохранять Катлинги с изображениями.",
    "Просмотр",
)

TRANSLATIONS["uk"] = (
    "Зберегти як файл…",
    "Збереження зображень",
    "Під час збереження зображень",
    "Питати щоразу",
    "Зберігати в папку",
    "Папка",
    "Змінити папку…",
    "Оберіть, як працює дія «Зберегти як файл» для Катлінгів із зображеннями. З опцією «Зберігати в папку» зображення потрапляють просто до обраної папки з унікальною назвою файлу, без запитань.",
    "Обрати",
    "Вибір папки для зображень",
    "Оберіть папку, в яку Катлінг зберігатиме Катлінги із зображеннями.",
    "Перегляд",
)

TRANSLATIONS["pl"] = (
    "Zapisz jako plik…",
    "Zapisywanie obrazów",
    "Podczas zapisywania obrazów",
    "Pytaj za każdym razem",
    "Zapisuj do folderu",
    "Folder",
    "Zmień folder…",
    "Wybierz, jak działa akcja „Zapisz jako plik” dla Cutlingów obrazów. Po wybraniu „Zapisuj do folderu” obrazy są zapisywane bezpośrednio w wybranym folderze z unikalną nazwą pliku, bez pytania.",
    "Wybierz",
    "Wybierz folder obrazów",
    "Wybierz folder, w którym Cutling będzie zapisywać Cutlingi obrazów.",
    "Podgląd",
)

TRANSLATIONS["cs"] = (
    "Uložit jako soubor…",
    "Ukládání obrázků",
    "Při ukládání obrázků",
    "Pokaždé se zeptat",
    "Ukládat do složky",
    "Složka",
    "Změnit složku…",
    "Zvolte, jak funguje akce „Uložit jako soubor“ pro obrázkové Cutlingy. S volbou „Ukládat do složky“ se obrázky ukládají rovnou do vybrané složky pod jedinečným názvem souboru, bez dotazu.",
    "Vybrat",
    "Vybrat složku s obrázky",
    "Vyberte složku, do které bude Cutling ukládat obrázkové Cutlingy.",
    "Náhled",
)

TRANSLATIONS["sk"] = (
    "Uložiť ako súbor…",
    "Ukladanie obrázkov",
    "Pri ukladaní obrázkov",
    "Vždy sa opýtať",
    "Ukladať do priečinka",
    "Priečinok",
    "Zmeniť priečinok…",
    "Vyberte, ako funguje akcia „Uložiť ako súbor“ pre obrázkové Cutlingy. S možnosťou „Ukladať do priečinka“ sa obrázky uložia priamo do vybraného priečinka s jedinečným názvom súboru, bez pýtania.",
    "Vybrať",
    "Vybrať priečinok s obrázkami",
    "Vyberte priečinok, do ktorého bude Cutling ukladať obrázkové Cutlingy.",
    "Náhľad",
)

TRANSLATIONS["sl"] = (
    "Shrani kot datoteko…",
    "Shranjevanje slik",
    "Pri shranjevanju slik",
    "Vsakič vprašaj",
    "Shrani v mapo",
    "Mapa",
    "Spremeni mapo…",
    "Izberi, kako deluje dejanje „Shrani kot datoteko“ za slikovne Cutlinge. Z možnostjo „Shrani v mapo“ se slike samodejno shranijo v izbrano mapo z edinstvenim imenom datoteke, brez vprašanja.",
    "Izberi",
    "Izberi mapo za slike",
    "Izberi mapo, kamor bo Cutling shranjeval slikovne Cutlinge.",
    "Predogled",
)
TRANSLATIONS["sl-SI"] = TRANSLATIONS["sl"]

TRANSLATIONS["hr"] = (
    "Spremi kao datoteku…",
    "Spremanje slika",
    "Prilikom spremanja slika",
    "Pitaj svaki put",
    "Spremi u mapu",
    "Mapa",
    "Promijeni mapu…",
    "Odaberite kako radi radnja „Spremi kao datoteku“ za slikovne Cutlinge. Uz „Spremi u mapu“ slike idu izravno u odabranu mapu pod jedinstvenim nazivom datoteke, bez upita.",
    "Odaberi",
    "Odaberi mapu za slike",
    "Odaberite mapu u koju će Cutling spremati slikovne Cutlinge.",
    "Pretpregled",
)

TRANSLATIONS["sr"] = (
    "Сачувај као фајл…",
    "Чување слика",
    "Приликом чувања слика",
    "Питај сваки пут",
    "Сачувај у фасциклу",
    "Фасцикла",
    "Промени фасциклу…",
    "Изабери како функционише радња „Сачувај као фајл” за Катлинге слика. Уз „Сачувај у фасциклу” слике се чувају директно у изабраној фасцикли са јединственим именом фајла, без питања.",
    "Изабери",
    "Избор фасцикле за слике",
    "Изабери фасциклу у коју ће Катлинг чувати Катлинге слика.",
    "Преглед",
)

TRANSLATIONS["bg"] = (
    "Запис като файл…",
    "Запис на изображения",
    "При запис на изображения",
    "Питай всеки път",
    "Запис в папка",
    "Папка",
    "Смяна на папка…",
    "Изберете как работи действието „Запис като файл“ за изображения Кътлинг. С „Запис в папка“ изображенията се записват направо в избраната папка с уникално име на файл, без питане.",
    "Избор",
    "Избор на папка за изображения",
    "Изберете папка, в която Кътлинг да записва изображения Кътлинг.",
    "Преглед",
)

# ───────── Other European ─────────

TRANSLATIONS["el"] = (
    "Αποθήκευση ως αρχείο…",
    "Αποθήκευση εικόνων",
    "Κατά την αποθήκευση εικόνων",
    "Ερώτηση κάθε φορά",
    "Αποθήκευση σε φάκελο",
    "Φάκελος",
    "Αλλαγή φακέλου…",
    "Επιλέξτε πώς λειτουργεί η ενέργεια «Αποθήκευση ως αρχείο» για τα Cutling εικόνας. Με «Αποθήκευση σε φάκελο» οι εικόνες αποθηκεύονται απευθείας στον επιλεγμένο φάκελο με μοναδικό όνομα αρχείου, χωρίς ερώτηση.",
    "Επιλογή",
    "Επιλογή φακέλου εικόνων",
    "Επιλέξτε έναν φάκελο στον οποίο το Cutling θα αποθηκεύει τα Cutling εικόνας.",
    "Προεπισκόπηση",
)

TRANSLATIONS["hu"] = (
    "Mentés fájlként…",
    "Képek mentése",
    "Képek mentésekor",
    "Kérdezzen mindig",
    "Mentés mappába",
    "Mappa",
    "Mappa módosítása…",
    "Állítsd be, hogyan működjön a „Mentés fájlként” művelet a kép-Cutlingoknál. A „Mentés mappába” kiválasztásakor a képek egyedi fájlnévvel egyenesen a kiválasztott mappába kerülnek, kérdés nélkül.",
    "Választás",
    "Képmappa választása",
    "Válassz mappát, ahová a Cutling a kép-Cutlingokat menti.",
    "Előnézet",
)

TRANSLATIONS["tr"] = (
    "Dosya olarak kaydet…",
    "Resim kaydetme",
    "Resimler kaydedilirken",
    "Her seferinde sor",
    "Klasöre kaydet",
    "Klasör",
    "Klasörü değiştir…",
    "Resim Cutling’leri için “Dosya olarak kaydet” eyleminin nasıl çalışacağını seç. “Klasöre kaydet” seçildiğinde resimler, sorulmadan, benzersiz bir dosya adıyla doğrudan seçtiğin klasöre gider.",
    "Seç",
    "Resim klasörü seç",
    "Cutling’in resim Cutling’lerini kaydedeceği bir klasör seç.",
    "Önizleme",
)

# ───────── East Asian ─────────

TRANSLATIONS["ja"] = (
    "ファイルとして保存…",
    "画像の保存",
    "画像を保存するとき",
    "毎回確認する",
    "フォルダに保存",
    "フォルダ",
    "フォルダを変更…",
    "画像カットリングに対する「ファイルとして保存」操作の動作を選択します。「フォルダに保存」を選ぶと、画像は確認なしで、選択したフォルダに一意のファイル名で直接保存されます。",
    "選択",
    "画像フォルダを選択",
    "カットリングが画像カットリングを保存するフォルダを選択してください。",
    "プレビュー",
)

TRANSLATIONS["ko"] = (
    "파일로 저장…",
    "이미지 저장",
    "이미지를 저장할 때",
    "매번 묻기",
    "폴더에 저장",
    "폴더",
    "폴더 변경…",
    "이미지 컷링에 대해 “파일로 저장” 동작이 작동하는 방식을 선택합니다. “폴더에 저장”을 사용하면 이미지가 묻지 않고 고유한 파일 이름으로 선택한 폴더에 바로 저장됩니다.",
    "선택",
    "이미지 폴더 선택",
    "컷링이 이미지 컷링을 저장할 폴더를 선택하세요.",
    "미리보기",
)

TRANSLATIONS["zh-Hans"] = (
    "存储为文件…",
    "图片存储",
    "存储图片时",
    "每次询问",
    "存储到文件夹",
    "文件夹",
    "更改文件夹…",
    "选择图片剪切片段的“存储为文件”操作的行为方式。选择“存储到文件夹”后，图片会以唯一文件名直接存入所选文件夹，不再询问。",
    "选取",
    "选取图片文件夹",
    "选取剪切片段用于存储图片剪切片段的文件夹。",
    "预览",
)

TRANSLATIONS["zh-Hant"] = (
    "儲存為檔案…",
    "圖片儲存",
    "儲存圖片時",
    "每次詢問",
    "儲存到檔案夾",
    "檔案夾",
    "更改檔案夾…",
    "選擇圖片剪切片段的「儲存為檔案」操作的運作方式。選擇「儲存到檔案夾」後，圖片會以唯一檔名直接儲存到所選的檔案夾，不再詢問。",
    "選擇",
    "選擇圖片檔案夾",
    "選擇剪切片段儲存圖片剪切片段的檔案夾。",
    "預覽",
)

TRANSLATIONS["vi"] = (
    "Lưu thành tệp…",
    "Lưu hình ảnh",
    "Khi lưu hình ảnh",
    "Hỏi mỗi lần",
    "Lưu vào thư mục",
    "Thư mục",
    "Đổi thư mục…",
    "Chọn cách hoạt động của thao tác “Lưu thành tệp” đối với cutling hình ảnh. Khi chọn “Lưu vào thư mục”, hình ảnh sẽ được lưu thẳng vào thư mục bạn chọn với tên tệp duy nhất, không hỏi lại.",
    "Chọn",
    "Chọn thư mục hình ảnh",
    "Chọn thư mục mà Cutling sẽ lưu các cutling hình ảnh.",
    "Xem trước",
)

TRANSLATIONS["th"] = (
    "บันทึกเป็นไฟล์…",
    "การบันทึกรูปภาพ",
    "เมื่อบันทึกรูปภาพ",
    "ถามทุกครั้ง",
    "บันทึกไปยังโฟลเดอร์",
    "โฟลเดอร์",
    "เปลี่ยนโฟลเดอร์…",
    "เลือกวิธีทำงานของการกระทำ “บันทึกเป็นไฟล์” สำหรับคัตลิงรูปภาพ ถ้าใช้ “บันทึกไปยังโฟลเดอร์” รูปภาพจะถูกบันทึกตรงไปยังโฟลเดอร์ที่คุณเลือกพร้อมชื่อไฟล์ที่ไม่ซ้ำกัน โดยไม่ถามอีก",
    "เลือก",
    "เลือกโฟลเดอร์รูปภาพ",
    "เลือกโฟลเดอร์ที่คัตลิงจะใช้บันทึกคัตลิงรูปภาพ",
    "ดูตัวอย่าง",
)

TRANSLATIONS["id"] = (
    "Simpan sebagai berkas…",
    "Penyimpanan gambar",
    "Saat menyimpan gambar",
    "Tanyakan setiap kali",
    "Simpan ke folder",
    "Folder",
    "Ubah folder…",
    "Pilih bagaimana tindakan “Simpan sebagai berkas” bekerja untuk cutling gambar. Dengan “Simpan ke folder”, gambar langsung tersimpan di folder yang Anda pilih dengan nama berkas unik, tanpa pertanyaan.",
    "Pilih",
    "Pilih folder gambar",
    "Pilih folder tempat Cutling akan menyimpan cutling gambar.",
    "Pratinjau",
)

TRANSLATIONS["ms"] = (
    "Simpan sebagai fail…",
    "Penyimpanan imej",
    "Semasa menyimpan imej",
    "Tanya setiap kali",
    "Simpan ke folder",
    "Folder",
    "Tukar folder…",
    "Pilih cara tindakan “Simpan sebagai fail” berfungsi untuk cutling imej. Dengan “Simpan ke folder”, imej terus disimpan ke folder pilihan anda dengan nama fail yang unik, tanpa soalan.",
    "Pilih",
    "Pilih folder imej",
    "Pilih folder tempat Cutling menyimpan cutling imej.",
    "Pratonton",
)

TRANSLATIONS["fil"] = (
    "I-save bilang file…",
    "Pag-save ng larawan",
    "Kapag nagse-save ng mga larawan",
    "Magtanong sa bawat pagkakataon",
    "I-save sa folder",
    "Folder",
    "Palitan ang folder…",
    "Piliin kung paano gumagana ang aksyong “I-save bilang file” para sa mga image cutling. Sa “I-save sa folder”, derecho mase-save ang mga larawan sa folder na iyong pinili na may natatanging pangalan ng file, nang walang tanong.",
    "Piliin",
    "Pumili ng folder ng larawan",
    "Pumili ng folder kung saan ise-save ng Cutling ang mga image cutling.",
    "Preview",
)

# ───────── Indian languages ─────────
# Note: pre-existing translations elsewhere in these files have some quality
# issues (Odia notably has English -s plural), but the new strings here are
# written from scratch with proper grammar.

TRANSLATIONS["hi"] = (
    "फ़ाइल के रूप में सहेजें…",
    "छवि सहेजना",
    "छवियाँ सहेजते समय",
    "हर बार पूछें",
    "फ़ोल्डर में सहेजें",
    "फ़ोल्डर",
    "फ़ोल्डर बदलें…",
    "छवि कटलिंग के लिए “फ़ाइल के रूप में सहेजें” क्रिया कैसे काम करे, यह चुनें। “फ़ोल्डर में सहेजें” के साथ, छवियाँ बिना पूछे आपके चुने हुए फ़ोल्डर में अनन्य फ़ाइल नाम के साथ सीधे सहेजी जाती हैं।",
    "चुनें",
    "छवि फ़ोल्डर चुनें",
    "एक फ़ोल्डर चुनें जहाँ कटलिंग छवि कटलिंग सहेजेगा।",
    "पूर्वावलोकन",
)

TRANSLATIONS["bn"] = (
    "ফাইল হিসাবে সংরক্ষণ…",
    "ছবি সংরক্ষণ",
    "ছবি সংরক্ষণের সময়",
    "প্রতিবার জিজ্ঞেস করো",
    "ফোল্ডারে সংরক্ষণ",
    "ফোল্ডার",
    "ফোল্ডার পরিবর্তন…",
    "ছবি কাটলিং-এর জন্য “ফাইল হিসাবে সংরক্ষণ” কাজটি কীভাবে কাজ করবে তা বেছে নিন। “ফোল্ডারে সংরক্ষণ” বেছে নিলে ছবি কোনো জিজ্ঞাসা ছাড়াই আপনার বেছে নেওয়া ফোল্ডারে অনন্য ফাইল নামে সরাসরি সংরক্ষিত হয়।",
    "বেছে নিন",
    "ছবির ফোল্ডার বেছে নিন",
    "এমন একটি ফোল্ডার বেছে নিন যেখানে কাটলিং ছবি কাটলিং সংরক্ষণ করবে।",
    "প্রাকদর্শন",
)
TRANSLATIONS["bn-BD"] = TRANSLATIONS["bn"]

TRANSLATIONS["gu"] = (
    "ફાઇલ તરીકે સાચવો…",
    "છબી સાચવણી",
    "છબીઓ સાચવતી વખતે",
    "દર વખતે પૂછો",
    "ફોલ્ડરમાં સાચવો",
    "ફોલ્ડર",
    "ફોલ્ડર બદલો…",
    "છબી કટલિંગ માટે “ફાઇલ તરીકે સાચવો” ક્રિયા કેવી રીતે કાર્ય કરે તે પસંદ કરો. “ફોલ્ડરમાં સાચવો” સાથે, છબીઓ પૂછ્યા વગર તમે પસંદ કરેલા ફોલ્ડરમાં અનન્ય ફાઇલ નામ સાથે સીધી સચવાય છે.",
    "પસંદ કરો",
    "છબી ફોલ્ડર પસંદ કરો",
    "એક ફોલ્ડર પસંદ કરો જ્યાં કટલિંગ છબી કટલિંગ સાચવશે.",
    "પૂર્વાવલોકન",
)
TRANSLATIONS["gu-IN"] = TRANSLATIONS["gu"]

TRANSLATIONS["mr"] = (
    "फाइल म्हणून जतन करा…",
    "प्रतिमा जतन करणे",
    "प्रतिमा जतन करताना",
    "प्रत्येक वेळी विचारा",
    "फोल्डरमध्ये जतन करा",
    "फोल्डर",
    "फोल्डर बदला…",
    "प्रतिमा कटलिंगसाठी “फाइल म्हणून जतन करा” क्रिया कशी कार्य करते ते निवडा. “फोल्डरमध्ये जतन करा” सोबत, प्रतिमा कोणतीही विचारणा न करता तुम्ही निवडलेल्या फोल्डरमध्ये अद्वितीय फाइलनावासह थेट जतन होतात.",
    "निवडा",
    "प्रतिमा फोल्डर निवडा",
    "कटलिंग जिथे प्रतिमा कटलिंग जतन करेल असे फोल्डर निवडा.",
    "पूर्वावलोकन",
)
TRANSLATIONS["mr-IN"] = TRANSLATIONS["mr"]

TRANSLATIONS["pa"] = (
    "ਫਾਈਲ ਵਜੋਂ ਸੰਭਾਲੋ…",
    "ਚਿੱਤਰ ਸੰਭਾਲ",
    "ਚਿੱਤਰ ਸੰਭਾਲਣ ਵੇਲੇ",
    "ਹਰ ਵਾਰੀ ਪੁੱਛੋ",
    "ਫੋਲਡਰ ਵਿੱਚ ਸੰਭਾਲੋ",
    "ਫੋਲਡਰ",
    "ਫੋਲਡਰ ਬਦਲੋ…",
    "ਚਿੱਤਰ ਕਟਲਿੰਗ ਲਈ “ਫਾਈਲ ਵਜੋਂ ਸੰਭਾਲੋ” ਕਾਰਵਾਈ ਕਿਵੇਂ ਕੰਮ ਕਰੇ, ਇਹ ਚੁਣੋ। “ਫੋਲਡਰ ਵਿੱਚ ਸੰਭਾਲੋ” ਨਾਲ, ਚਿੱਤਰ ਬਿਨਾਂ ਪੁੱਛੇ ਤੁਹਾਡੇ ਚੁਣੇ ਫੋਲਡਰ ਵਿੱਚ ਵਿਲੱਖਣ ਫਾਈਲ ਨਾਮ ਨਾਲ ਸਿੱਧੇ ਸੰਭਾਲੇ ਜਾਂਦੇ ਹਨ।",
    "ਚੁਣੋ",
    "ਚਿੱਤਰ ਫੋਲਡਰ ਚੁਣੋ",
    "ਉਹ ਫੋਲਡਰ ਚੁਣੋ ਜਿੱਥੇ ਕਟਲਿੰਗ ਚਿੱਤਰ ਕਟਲਿੰਗ ਸੰਭਾਲੇਗਾ।",
    "ਝਲਕ",
)
TRANSLATIONS["pa-IN"] = TRANSLATIONS["pa"]

TRANSLATIONS["or"] = (
    "ଫାଇଲ ଭାବେ ସଞ୍ଚୟ କରନ୍ତୁ…",
    "ଛବି ସଞ୍ଚୟ",
    "ଛବି ସଞ୍ଚୟ କରିବା ସମୟରେ",
    "ପ୍ରତ୍ୟେକ ଥର ପଚାରନ୍ତୁ",
    "ଫୋଲ୍ଡରରେ ସଞ୍ଚୟ କରନ୍ତୁ",
    "ଫୋଲ୍ଡର",
    "ଫୋଲ୍ଡର ବଦଳାନ୍ତୁ…",
    "ଛବି କଟ୍‌ଲିଂ ପାଇଁ “ଫାଇଲ ଭାବେ ସଞ୍ଚୟ କରନ୍ତୁ” କାର୍ଯ୍ୟ କିପରି କାମ କରେ ତାହା ବାଛନ୍ତୁ। “ଫୋଲ୍ଡରରେ ସଞ୍ଚୟ କରନ୍ତୁ” ସହିତ, ଛବିଗୁଡ଼ିକ ବିନା ପଚାରି ଆପଣ ବାଛିଥିବା ଫୋଲ୍ଡରରେ ଅନନ୍ୟ ଫାଇଲ ନାମ ସହିତ ସିଧାସଳଖ ସଞ୍ଚୟ ହୁଏ।",
    "ବାଛନ୍ତୁ",
    "ଛବି ଫୋଲ୍ଡର ବାଛନ୍ତୁ",
    "ଏକ ଫୋଲ୍ଡର ବାଛନ୍ତୁ ଯେଉଁଠି କଟ୍‌ଲିଂ ଛବି କଟ୍‌ଲିଂଗୁଡ଼ିକ ସଞ୍ଚୟ କରିବ।",
    "ପୂର୍ବାବଲୋକନ",
)
TRANSLATIONS["or-IN"] = TRANSLATIONS["or"]

TRANSLATIONS["ta"] = (
    "கோப்பாகச் சேமி…",
    "படச் சேமிப்பு",
    "படங்களைச் சேமிக்கும்போது",
    "ஒவ்வொரு முறையும் கேள்",
    "கோப்புறையில் சேமி",
    "கோப்புறை",
    "கோப்புறையை மாற்று…",
    "படக் கட்லிங்குகளுக்கான “கோப்பாகச் சேமி” செயல் எவ்வாறு வேலை செய்ய வேண்டுமென தேர்வுசெய்க. “கோப்புறையில் சேமி” தேர்வுடன், படங்கள் எந்தக் கேள்வியும் இன்றி நீங்கள் தேர்வுசெய்த கோப்புறையில் தனித்துவமான கோப்புப் பெயருடன் நேரடியாகச் சேமிக்கப்படும்.",
    "தேர்வுசெய்",
    "படக் கோப்புறையைத் தேர்வுசெய்",
    "கட்லிங்கு படக் கட்லிங்குகளைச் சேமிக்கும் கோப்புறையைத் தேர்வுசெய்க.",
    "முன்தோற்றம்",
)
TRANSLATIONS["ta-IN"] = TRANSLATIONS["ta"]

TRANSLATIONS["te"] = (
    "ఫైల్‌గా సేవ్ చేయి…",
    "చిత్రాల సేవ్",
    "చిత్రాలను సేవ్ చేస్తున్నప్పుడు",
    "ప్రతిసారీ అడుగు",
    "ఫోల్డర్‌లో సేవ్ చేయి",
    "ఫోల్డర్",
    "ఫోల్డర్ మార్చు…",
    "చిత్రాల కట్లింగ్ కోసం “ఫైల్‌గా సేవ్ చేయి” చర్య ఎలా పనిచేయాలో ఎంచుకోండి. “ఫోల్డర్‌లో సేవ్ చేయి” తో, చిత్రాలు అడగకుండానే మీరు ఎంచుకున్న ఫోల్డర్‌లో ప్రత్యేకమైన ఫైల్ పేరుతో నేరుగా సేవ్ అవుతాయి.",
    "ఎంచుకో",
    "చిత్రాల ఫోల్డర్ ఎంచుకో",
    "కట్లింగ్ చిత్రాల కట్లింగ్‌ను సేవ్ చేసే ఫోల్డర్‌ను ఎంచుకోండి.",
    "ముందస్తు వీక్షణ",
)
TRANSLATIONS["te-IN"] = TRANSLATIONS["te"]

TRANSLATIONS["kn"] = (
    "ಫೈಲ್ ಆಗಿ ಉಳಿಸಿ…",
    "ಚಿತ್ರ ಉಳಿಸುವಿಕೆ",
    "ಚಿತ್ರಗಳನ್ನು ಉಳಿಸುವಾಗ",
    "ಪ್ರತಿ ಬಾರಿ ಕೇಳಿ",
    "ಫೋಲ್ಡರ್‌ಗೆ ಉಳಿಸಿ",
    "ಫೋಲ್ಡರ್",
    "ಫೋಲ್ಡರ್ ಬದಲಿಸಿ…",
    "ಚಿತ್ರ ಕಟ್ಲಿಂಗ್‌ಗಳಿಗಾಗಿ “ಫೈಲ್ ಆಗಿ ಉಳಿಸಿ” ಕ್ರಿಯೆಯು ಹೇಗೆ ಕಾರ್ಯನಿರ್ವಹಿಸಬೇಕು ಎಂಬುದನ್ನು ಆಯ್ಕೆಮಾಡಿ. “ಫೋಲ್ಡರ್‌ಗೆ ಉಳಿಸಿ” ಆಯ್ಕೆಯೊಂದಿಗೆ, ಚಿತ್ರಗಳು ಯಾವುದೇ ಪ್ರಶ್ನೆಯಿಲ್ಲದೆ ನೀವು ಆಯ್ಕೆಮಾಡಿದ ಫೋಲ್ಡರ್‌ಗೆ ಅನನ್ಯ ಫೈಲ್ ಹೆಸರಿನೊಂದಿಗೆ ನೇರವಾಗಿ ಉಳಿಸಲ್ಪಡುತ್ತವೆ.",
    "ಆಯ್ಕೆಮಾಡಿ",
    "ಚಿತ್ರ ಫೋಲ್ಡರ್ ಆಯ್ಕೆಮಾಡಿ",
    "ಕಟ್ಲಿಂಗ್ ಚಿತ್ರ ಕಟ್ಲಿಂಗ್‌ಗಳನ್ನು ಉಳಿಸುವ ಫೋಲ್ಡರ್ ಆಯ್ಕೆಮಾಡಿ.",
    "ಮುನ್ನೋಟ",
)
TRANSLATIONS["kn-IN"] = TRANSLATIONS["kn"]

TRANSLATIONS["ml"] = (
    "ഫയലായി സംരക്ഷിക്കുക…",
    "ചിത്രം സംരക്ഷണം",
    "ചിത്രങ്ങൾ സംരക്ഷിക്കുമ്പോൾ",
    "എല്ലായ്പ്പോഴും ചോദിക്കുക",
    "ഫോൾഡറിലേക്ക് സംരക്ഷിക്കുക",
    "ഫോൾഡർ",
    "ഫോൾഡർ മാറ്റുക…",
    "ചിത്ര കട്ട്‌ലിംഗുകൾക്കായി “ഫയലായി സംരക്ഷിക്കുക” എന്ന ക്രിയ എങ്ങനെ പ്രവർത്തിക്കണമെന്ന് തിരഞ്ഞെടുക്കുക. “ഫോൾഡറിലേക്ക് സംരക്ഷിക്കുക” ഉപയോഗിച്ച്, ചിത്രങ്ങൾ ചോദ്യങ്ങളില്ലാതെ നിങ്ങൾ തിരഞ്ഞെടുത്ത ഫോൾഡറിലേക്ക് സവിശേഷമായ ഫയൽ പേരോടെ നേരിട്ട് സംരക്ഷിക്കപ്പെടും.",
    "തിരഞ്ഞെടുക്കുക",
    "ചിത്ര ഫോൾഡർ തിരഞ്ഞെടുക്കുക",
    "കട്ട്‌ലിംഗ് ചിത്ര കട്ട്‌ലിംഗുകൾ സംരക്ഷിക്കുന്ന ഫോൾഡർ തിരഞ്ഞെടുക്കുക.",
    "പ്രിവ്യൂ",
)
TRANSLATIONS["ml-IN"] = TRANSLATIONS["ml"]

# ───────── Semitic / Iranian / Urdu / Swahili ─────────

TRANSLATIONS["ar"] = (
    "حفظ كملف…",
    "حفظ الصور",
    "عند حفظ الصور",
    "اسأل في كل مرة",
    "حفظ في مجلد",
    "مجلد",
    "تغيير المجلد…",
    "اختر كيفية عمل إجراء «حفظ كملف» لكاتلينجات الصور. مع «حفظ في مجلد»، تُحفظ الصور مباشرة في المجلد الذي تختاره باسم ملف فريد، دون سؤال.",
    "اختر",
    "اختر مجلد الصور",
    "اختر مجلداً يحفظ فيه كاتلينج كاتلينجات الصور.",
    "معاينة",
)
TRANSLATIONS["ar-SA"] = TRANSLATIONS["ar"]

TRANSLATIONS["he"] = (
    "שמור כקובץ…",
    "שמירת תמונות",
    "בעת שמירת תמונות",
    "שאל בכל פעם",
    "שמור לתיקייה",
    "תיקייה",
    "החלף תיקייה…",
    "בחר כיצד פועלת הפעולה “שמור כקובץ” עבור קאטלינגים של תמונות. עם “שמור לתיקייה”, התמונות נשמרות ישירות לתיקייה שבחרת בשם קובץ ייחודי, ללא שאלה.",
    "בחר",
    "בחר תיקיית תמונות",
    "בחר תיקייה שבה קאטלינג ישמור את קאטלינגים של תמונות.",
    "תצוגה מקדימה",
)

TRANSLATIONS["fa"] = (
    "ذخیره به‌عنوان فایل…",
    "ذخیرهٔ تصاویر",
    "هنگام ذخیرهٔ تصاویر",
    "هر بار بپرس",
    "ذخیره در پوشه",
    "پوشه",
    "تغییر پوشه…",
    "انتخاب کنید که عمل “ذخیره به‌عنوان فایل” برای کاتلینگ‌های تصویر چگونه کار کند. با “ذخیره در پوشه” تصاویر بدون پرسش، مستقیماً با نام فایل یکتا در پوشهٔ انتخابی شما ذخیره می‌شوند.",
    "انتخاب",
    "انتخاب پوشهٔ تصاویر",
    "پوشه‌ای انتخاب کنید که کاتلینگ کاتلینگ‌های تصویر را در آن ذخیره کند.",
    "پیش‌نمایش",
)

TRANSLATIONS["ur"] = (
    "بطور فائل محفوظ کریں…",
    "تصویروں کی حفاظت",
    "تصاویر محفوظ کرتے وقت",
    "ہر بار پوچھیں",
    "فولڈر میں محفوظ کریں",
    "فولڈر",
    "فولڈر تبدیل کریں…",
    "منتخب کریں کہ تصویری کٹلنگ کے لیے “بطور فائل محفوظ کریں” عمل کیسے کام کرے۔ “فولڈر میں محفوظ کریں” کے ساتھ، تصاویر بغیر پوچھے آپ کے منتخب کردہ فولڈر میں منفرد فائل نام کے ساتھ براہ راست محفوظ ہو جاتی ہیں۔",
    "منتخب کریں",
    "تصویری فولڈر منتخب کریں",
    "ایک فولڈر منتخب کریں جہاں کٹلنگ تصویری کٹلنگ محفوظ کرے گا۔",
    "پیش منظر",
)
TRANSLATIONS["ur-PK"] = TRANSLATIONS["ur"]

TRANSLATIONS["sw"] = (
    "Hifadhi kama faili…",
    "Uhifadhi wa picha",
    "Wakati wa kuhifadhi picha",
    "Uliza kila wakati",
    "Hifadhi kwenye folda",
    "Folda",
    "Badilisha folda…",
    "Chagua jinsi kitendo cha “Hifadhi kama faili” kinavyofanya kazi kwa Cutling za picha. Ukichagua “Hifadhi kwenye folda”, picha huhifadhiwa moja kwa moja kwenye folda uliyochagua kwa jina la faili la kipekee, bila kuuliza.",
    "Chagua",
    "Chagua folda ya picha",
    "Chagua folda ambapo Cutling itahifadhi Cutling za picha.",
    "Onyesho la awali",
)


# ───────── Apply ─────────

def existing_keys(path: Path):
    if not path.exists():
        return set()
    text = path.read_text(encoding="utf-8")
    pattern = re.compile(r'"((?:[^"\\]|\\.)*)"\s*=', re.DOTALL)
    return {m.group(1).replace('\\"', '"').replace("\\\\", "\\") for m in pattern.finditer(text)}


def escape(s: str) -> str:
    return s.replace("\\", "\\\\").replace('"', '\\"')


def apply_locale(locale: str, values) -> str:
    lproj = CUTLING_DIR / f"{locale}.lproj"
    target = lproj / "Localizable.strings"
    if not target.exists():
        return f"missing dir {locale}"
    present = existing_keys(target)
    pairs = []
    for key, value in zip(KEYS, values):
        if key in present:
            continue
        pairs.append((key, value))
    if not pairs:
        return "skip"
    lines = ["", "/* MARK: - Image Saving (macOS) */"]
    for k, v in pairs:
        lines.append(f'"{escape(k)}" = "{escape(v)}";')
    body = "\n".join(lines) + "\n"
    with target.open("a", encoding="utf-8") as f:
        f.write(("\n" if target.stat().st_size > 0 else "") + body)
    return f"+{len(pairs)}"


def main():
    missing_locales = []
    for lproj in sorted(CUTLING_DIR.glob("*.lproj")):
        locale = lproj.name.replace(".lproj", "")
        if locale not in TRANSLATIONS:
            missing_locales.append(locale)
            continue
        result = apply_locale(locale, TRANSLATIONS[locale])
        print(f"  {locale}: {result}")
    if missing_locales:
        print(f"\nNo hardcoded translation for: {', '.join(missing_locales)}")


if __name__ == "__main__":
    main()
