"""App Store storefront ids, sent as the X-Apple-Store-Front header (<id>-1,29).

Every id here answered a live query on 2026-10-01. Add a country only after
checking its id with a live request that returns that country's results.
"""

STOREFRONTS = {
    "US": 143441, "GB": 143444, "AU": 143460, "CA": 143455, "DE": 143443, "FR": 143442,
    "IT": 143450, "ES": 143454, "NL": 143452, "JP": 143462, "KR": 143466, "CN": 143465,
    "TW": 143470, "HK": 143463, "RU": 143469, "BR": 143503, "PT": 143453, "MX": 143468,
    "ID": 143476, "IN": 143467, "TR": 143480, "PL": 143478, "SA": 143479, "IL": 143491,
    "TH": 143475, "VN": 143471, "MY": 143473, "SE": 143456, "NO": 143457, "DK": 143458,
    "FI": 143447, "CZ": 143489, "SK": 143496, "HU": 143482, "RO": 143487, "GR": 143448,
    "HR": 143494, "SI": 143499, "UA": 143492, "PK": 143477, "AE": 143481,
    # added 2026-10-01; each id verified live (MZStore search response meta.storefront.cc matched)
    "PH": 143474, "KE": 143529, "EE": 143518, "LV": 143519, "LT": 143520, "BG": 143526, "RS": 143500,
}
