defmodule PaymentsApi.Payments.Currencies do
  alias PaymentsApi.Payments.Currencies.AlphaVantageApiClient

  @currencies %{
    AED: %{name: "UAE Dirham", symbol: "د.إ", exponent: 2, number: 784},
    AFN: %{name: "Afghani", symbol: "؋", exponent: 2, number: 971},
    ALL: %{name: "Lek", symbol: "Lek", exponent: 2, number: 008},
    AMD: %{name: "Armenian Dram", symbol: "AMD", exponent: 2, number: 051},
    ANG: %{name: "Netherlands Antillian Guilder", symbol: "ƒ", exponent: 2, number: 532},
    AOA: %{name: "Kwanza", symbol: "Kz", exponent: 2, number: 973},
    ARS: %{name: "Argentine Peso", symbol: "$", exponent: 2, number: 032},
    AUD: %{name: "Australian Dollar", symbol: "$", exponent: 2, number: 036},
    AWG: %{name: "Aruban Guilder", symbol: "ƒ", exponent: 2, number: 533},
    AZN: %{name: "Azerbaijanian Manat", symbol: "ман", exponent: 2, number: 944},
    BAM: %{name: "Convertible Marks", symbol: "KM", exponent: 2, number: 977},
    BBD: %{name: "Barbados Dollar", symbol: "$", exponent: 2, number: 052},
    BDT: %{name: "Taka", symbol: "৳", exponent: 2, number: 050},
    BGN: %{name: "Bulgarian Lev", symbol: "лв", exponent: 2, number: 975},
    BHD: %{name: "Bahraini Dinar", symbol: ".د.ب", exponent: 3, number: 048},
    BIF: %{name: "Burundi Franc", symbol: "FBu", exponent: 0, number: 108},
    BMD: %{
      name: "Bermudian Dollar (customarily known as Bermuda Dollar)",
      symbol: "$",
      exponent: 2,
      number: 060
    },
    BND: %{name: "Brunei Dollar", symbol: "$", exponent: 2, number: 096},
    BOB: %{name: "Boliviano Mvdol", symbol: "$b", exponent: 2, number: 068},
    BOV: %{name: "Boliviano Mvdol", symbol: "$b", exponent: 2, number: 984},
    BRL: %{name: "Brazilian Real", symbol: "R$", exponent: 2, number: 986},
    BSD: %{name: "Bahamian Dollar", symbol: "$", exponent: 2, number: 044},
    BTN: %{name: "Indian Rupee Ngultrum", symbol: "Nu.", exponent: 2, number: 064},
    BWP: %{name: "Pula", symbol: "P", exponent: 2, number: 072},
    BYN: %{name: "Belarusian Ruble", symbol: "p.", exponent: 2, number: 933},
    BYR: %{name: "Belarusian Ruble", symbol: "p.", exponent: 0, number: 933},
    BZD: %{name: "Belize Dollar", symbol: "BZ$", exponent: 2, number: 084},
    CAD: %{name: "Canadian Dollar", symbol: "Can$", exponent: 2, number: 124},
    CDF: %{name: "Congolese Franc", symbol: "CF", exponent: 2, number: 976},
    CHF: %{name: "Swiss Franc", symbol: "CHF", exponent: 2, number: 756},
    CLF: %{name: "Chilean Peso Unidades de fomento", symbol: "$", exponent: 4, number: 990},
    CLP: %{name: "Chilean Peso Unidades de fomento", symbol: "$", exponent: 0, number: 152},
    CNY: %{name: "Yuan Renminbi", symbol: "¥", exponent: 2, number: 156},
    COP: %{name: "Colombian Peso", symbol: "$", exponent: 2, number: 170},
    COU: %{name: "Colombian Peso Unidad de Valor Real", symbol: "$", exponent: 2, number: 970},
    CRC: %{name: "Costa Rican Colon", symbol: "₡", exponent: 2, number: 188},
    CUC: %{name: "Cuban Peso Peso Convertible", symbol: "₱", exponent: 2, number: 931},
    CUP: %{name: "Cuban Peso Peso Convertible", symbol: "₱", exponent: 2, number: 192},
    CVE: %{name: "Cape Verde Escudo", symbol: "$", exponent: 0, number: 132},
    CZK: %{name: "Czech Koruna", symbol: "Kč", exponent: 2, number: 203},
    DJF: %{name: "Djibouti Franc", symbol: "Fdj", exponent: 0, number: 262},
    DKK: %{name: "Danish Krone", symbol: "kr.", exponent: 2, number: 208},
    DOP: %{name: "Dominican Peso", symbol: "RD$", exponent: 2, number: 214},
    DZD: %{name: "Algerian Dinar", symbol: "دج", exponent: 2, number: 012},
    EEK: %{name: "Kroon", symbol: "KR", exponent: 2, number: 233},
    EGP: %{name: "Egyptian Pound", symbol: "£", exponent: 2, number: 818},
    ERN: %{name: "Nakfa", symbol: "Nfk", exponent: 2, number: 232},
    ETB: %{name: "Ethiopian Birr", symbol: "Br", exponent: 2, number: 230},
    EUR: %{name: "Euro", symbol: "€", exponent: 2, number: 978},
    FJD: %{name: "Fiji Dollar", symbol: "$", exponent: 2, number: 242},
    FKP: %{name: "Falkland Islands Pound", symbol: "£", exponent: 2, number: 238},
    GBP: %{name: "Pound Sterling", symbol: "£", exponent: 2, number: 826},
    GEL: %{name: "Lari", symbol: "₾", exponent: 2, number: 981},
    GHS: %{name: "Cedi", symbol: "GH₵", exponent: 2, number: 936},
    GIP: %{name: "Gibraltar Pound", symbol: "£", exponent: 2, number: 292},
    GMD: %{name: "Dalasi", symbol: "D", exponent: 2, number: 270},
    GNF: %{name: "Guinea Franc", symbol: "FG", exponent: 0, number: 324},
    GTQ: %{name: "Quetzal", symbol: "Q", exponent: 2, number: 320},
    GYD: %{name: "Guyana Dollar", symbol: "$", exponent: 2, number: 328},
    HKD: %{name: "Hong Kong Dollar", symbol: "$", exponent: 2, number: 344},
    HNL: %{name: "Lempira", symbol: "L", exponent: 2, number: 340},
    HRK: %{name: "Croatian Kuna", symbol: "kn", exponent: 2, number: 191},
    HTG: %{name: "Gourde US Dollar", symbol: " ", exponent: 2, number: 332},
    HUF: %{name: "Forint", symbol: "Ft", exponent: 2, number: 348},
    IDR: %{name: "Rupiah", symbol: "Rp", exponent: 2, number: 360},
    ILS: %{name: "New Israeli Sheqel", symbol: "₪", exponent: 2, number: 376},
    INR: %{name: "Indian Rupee", symbol: "₹", exponent: 2, number: 356},
    IQD: %{name: "Iraqi Dinar", symbol: "‎ع.د", exponent: 3, number: 368},
    IRR: %{name: "Iranian Rial", symbol: "﷼", exponent: 2, number: 364},
    ISK: %{name: "Iceland Krona", symbol: "kr", exponent: 0, number: 352},
    JMD: %{name: "Jamaican Dollar", symbol: "J$", exponent: 2, number: 388},
    JOD: %{name: "Jordanian Dinar", symbol: "JOD", exponent: 3, number: 400},
    JPY: %{name: "Yen", symbol: "¥", exponent: 0, number: 392},
    KES: %{name: "Kenyan Shilling", symbol: "KSh", exponent: 2, number: 404},
    KGS: %{name: "Som", symbol: "лв", exponent: 2, number: 417},
    KHR: %{name: "Riel", symbol: "៛", exponent: 2, number: 116},
    KMF: %{name: "Comoro Franc", symbol: "CF", exponent: 0, number: 174},
    KPW: %{name: "North Korean Won", symbol: "₩", exponent: 2, number: 408},
    KRW: %{name: "Won", symbol: "₩", exponent: 0, number: 410},
    KWD: %{name: "Kuwaiti Dinar", symbol: "د.ك", exponent: 3, number: 414},
    KYD: %{name: "Cayman Islands Dollar", symbol: "$", exponent: 2, number: 136},
    KZT: %{name: "Tenge", symbol: "лв", exponent: 2, number: 398},
    LAK: %{name: "Kip", symbol: "₭", exponent: 2, number: 418},
    LBP: %{name: "Lebanese Pound", symbol: "£", exponent: 2, number: 422},
    LKR: %{name: "Sri Lanka Rupee", symbol: "₨", exponent: 2, number: 144},
    LRD: %{name: "Liberian Dollar", symbol: "$", exponent: 2, number: 430},
    LSL: %{name: "Rand Loti", symbol: " ", exponent: 2, number: 426},
    LTL: %{name: "Lithuanian Litas", symbol: "Lt", exponent: 2, number: 440},
    LVL: %{name: "Latvian Lats", symbol: "Ls", exponent: 2, number: 428},
    LYD: %{name: "Libyan Dinar", symbol: "ل.د", exponent: 3, number: 434},
    MAD: %{name: "Moroccan Dirham", symbol: "د.م.", exponent: 2, number: 504},
    MDL: %{name: "Moldovan Leu", symbol: "MDL", exponent: 2, number: 498},
    MGA: %{name: "Malagasy Ariary", symbol: "Ar", exponent: 2, number: 969},
    MKD: %{name: "Denar", symbol: "ден", exponent: 2, number: 807},
    MMK: %{name: "Kyat", symbol: "K", exponent: 2, number: 104},
    MNT: %{name: "Tugrik", symbol: "₮", exponent: 2, number: 496},
    MOP: %{name: "Pataca", symbol: "MOP$", exponent: 2, number: 446},
    MRO: %{name: "Ouguiya", symbol: "UM", exponent: 2, number: 478},
    MRU: %{name: "Ouguiya", symbol: "UM", exponent: 2, number: 929},
    MUR: %{name: "Mauritius Rupee", symbol: "₨", exponent: 2, number: 480},
    MVR: %{name: "Rufiyaa", symbol: "Rf", exponent: 2, number: 462},
    MWK: %{name: "Kwacha", symbol: "MK", exponent: 2, number: 454},
    MXN: %{name: "Mexican Peso", symbol: "$", exponent: 2, number: 484},
    MXV: %{
      name: "Mexican Peso Mexican Unidad de Inversion (UDI)",
      symbol: "UDI",
      exponent: 2,
      number: 979
    },
    MYR: %{name: "Malaysian Ringgit", symbol: "RM", exponent: 2, number: 458},
    MZN: %{name: "Metical", symbol: "MT", exponent: 2, number: 943},
    NAD: %{name: "Rand Namibia Dollar", symbol: "$", exponent: 2, number: 516},
    NGN: %{name: "Naira", symbol: "₦", exponent: 2, number: 566},
    NIO: %{name: "Cordoba Oro", symbol: "C$", exponent: 2, number: 558},
    NOK: %{name: "Norwegian Krone", symbol: "kr", exponent: 2, number: 578},
    NPR: %{name: "Nepalese Rupee", symbol: "₨", exponent: 2, number: 524},
    NZD: %{name: "New Zealand Dollar", symbol: "$", exponent: 2, number: 554},
    OMR: %{name: "Rial Omani", symbol: "﷼", exponent: 3, number: 512},
    PAB: %{name: "Balboa US Dollar", symbol: "B/.", exponent: 2, number: 590},
    PEN: %{name: "Nuevo Sol", symbol: "S/", exponent: 2, number: 604},
    PGK: %{name: "Kina", symbol: "K", exponent: 2, number: 598},
    PHP: %{name: "Philippine Peso", symbol: "₱", exponent: 2, number: 608},
    PKR: %{name: "Pakistan Rupee", symbol: "₨", exponent: 2, number: 586},
    PLN: %{name: "Zloty", symbol: "zł", exponent: 2, number: 985},
    PYG: %{name: "Guarani", symbol: "₲", exponent: 0, number: 600},
    QAR: %{name: "Qatari Rial", symbol: "﷼", exponent: 2, number: 634},
    RON: %{name: "New Leu", symbol: "lei", exponent: 2, number: 946},
    RSD: %{name: "Serbian Dinar", symbol: "Дин.", exponent: 2, number: 941},
    RUB: %{name: "Russian Ruble", symbol: "₽", exponent: 2, number: 643},
    RWF: %{name: "Rwanda Franc", symbol: " ", exponent: 0, number: 646},
    SAR: %{name: "Saudi Riyal", symbol: "﷼", exponent: 2, number: 682},
    SBD: %{name: "Solomon Islands Dollar", symbol: "$", exponent: 2, number: 090},
    SCR: %{name: "Seychelles Rupee", symbol: "₨", exponent: 2, number: 690},
    SDG: %{name: "Sudanese Pound", symbol: "SDG", exponent: 2, number: 938},
    SEK: %{name: "Swedish Krona", symbol: "kr", exponent: 2, number: 752},
    SGD: %{name: "Singapore Dollar", symbol: "S$", exponent: 2, number: 702},
    SHP: %{name: "Saint Helena Pound", symbol: "£", exponent: 2, number: 654},
    SLE: %{name: "Leone", symbol: "Le", exponent: 2, number: 925},
    SLL: %{name: "Leone", symbol: "Le", exponent: 2, number: 694},
    SOS: %{name: "Somali Shilling", symbol: "S", exponent: 2, number: 706},
    SRD: %{name: "Surinam Dollar", symbol: "$", exponent: 2, number: 968},
    SSP: %{name: "South Sudanese Pound", symbol: "SS£", exponent: 2, number: 728},
    STD: %{name: "Dobra", symbol: "Db", exponent: 2, number: 678},
    STN: %{name: "Dobra", symbol: "Db", exponent: 2, number: 930},
    SVC: %{name: "El Salvador Colon US Dollar", symbol: "$", exponent: 2, number: 222},
    SYP: %{name: "Syrian Pound", symbol: "£", exponent: 2, number: 760},
    SZL: %{name: "Lilangeni", symbol: "E", exponent: 2, number: 748},
    THB: %{name: "Baht", symbol: "฿", exponent: 2, number: 764},
    TJS: %{name: "Somoni", symbol: " ", exponent: 2, number: 972},
    TMT: %{name: "Manat", symbol: "₼", exponent: 2, number: 934},
    TND: %{name: "Tunisian Dinar", symbol: "د.ت", exponent: 2, number: 788},
    TOP: %{name: "Pa'anga", symbol: "T$", exponent: 2, number: 776},
    TRY: %{name: "Turkish Lira", symbol: "TL", exponent: 2, number: 949},
    TTD: %{name: "Trinidad and Tobago Dollar", symbol: "TT$", exponent: 2, number: 780},
    TWD: %{name: "New Taiwan Dollar", symbol: "NT$", exponent: 2, number: 901},
    TZS: %{name: "Tanzanian Shilling", symbol: "Tsh", exponent: 2, number: 834},
    UAH: %{name: "Hryvnia", symbol: "₴", exponent: 2, number: 980},
    UGX: %{name: "Uganda Shilling", symbol: "Ush", exponent: 0, number: 800},
    USD: %{name: "US Dollar", symbol: "$", exponent: 2, number: 840},
    USN: %{name: "US Dollar next-day funds", symbol: "$", exponent: 2, number: 997},
    UYI: %{
      name: "Peso Uruguayo Uruguay Peso en Unidades Indexadas",
      symbol: "$U",
      exponent: 0,
      number: 940
    },
    UYU: %{
      name: "Peso Uruguayo Uruguay Peso en Unidades Indexadas",
      symbol: "$U",
      exponent: 2,
      number: 858
    },
    UZS: %{name: "Uzbekistan Sum", symbol: "лв", exponent: 2, number: 860},
    VEF: %{name: "Bolivar Fuerte", symbol: "Bs", exponent: 2, number: 937},
    VES: %{name: "Venezuelan Bolivar Soberano", symbol: "Bs", exponent: 2, number: 928},
    VND: %{name: "Dong", symbol: "₫", exponent: 0, number: 704},
    VUV: %{name: "Vatu", symbol: "VT", exponent: 0, number: 548},
    WST: %{name: "Tala", symbol: "WS$", exponent: 2, number: 882},
    XAF: %{name: "CFA Franc BEAC", symbol: "FCFA", exponent: 0, number: 950},
    XAG: %{name: "Silver", symbol: " ", exponent: 2, number: 961},
    XAU: %{name: "Gold", symbol: " ", exponent: 2, number: 959},
    XBA: %{
      name: "Bond Markets Units European Composite Unit (EURCO)",
      symbol: " ",
      exponent: 2,
      number: 955
    },
    XBB: %{name: "European Monetary Unit (E.M.U.-6)", symbol: " ", exponent: 2, number: 956},
    XBC: %{name: "European Unit of Account 9(E.U.A.-9)", symbol: " ", exponent: 2, number: 957},
    XBD: %{name: "European Unit of Account 17(E.U.A.-17)", symbol: " ", exponent: 2, number: 958},
    XCD: %{name: "East Caribbean Dollar", symbol: "$", exponent: 2, number: 951},
    XDR: %{name: "SDR", symbol: " ", exponent: 2, number: 960},
    XFU: %{name: "UIC-Franc", symbol: " ", exponent: 2, number: 000},
    XOF: %{name: "CFA Franc BCEAO", symbol: " ", exponent: 0, number: 952},
    XPD: %{name: "Palladium", symbol: " ", exponent: 2, number: 964},
    XPF: %{name: "CFP Franc", symbol: " ", exponent: 0, number: 953},
    XPT: %{name: "Platinum", symbol: " ", exponent: 2, number: 962},
    XTS: %{
      name: "Codes specifically reserved for testing purposes",
      symbol: " ",
      exponent: 2,
      number: 963
    },
    XSU: %{name: "Sucre", symbol: " ", exponent: 2, number: 994},
    XUA: %{name: "ADB Unit of Account", symbol: " ", exponent: 2, number: 965},
    YER: %{name: "Yemeni Rial", symbol: "﷼", exponent: 2, number: 886},
    ZAR: %{name: "Rand", symbol: "R", exponent: 2, number: 710},
    ZMW: %{name: "Zambian Kwacha", symbol: "ZK", exponent: 2, number: 967},
    ZWL: %{name: "Zimbabwe Dollar", symbol: "$", exponent: 2, number: 932}
  }

  @supported_currencies Application.compile_env(:payments_api, :supported_currencies)

  @spec all() :: map
  def all, do: @currencies

  @spec find_by(currency :: String.t()) :: map
  def find_by(currency) when is_binary(currency) do
    currency |> get_currency_atom() |> find_by()
  end

  @spec find_by(currency :: atom) :: map
  def find_by(currency) when is_atom(currency) do
    Map.filter(@currencies, fn {key, _value} -> key === currency end)
  end

  @spec supported?(currency :: String.t()) :: boolean
  def supported?(currency) when is_binary(currency) do
    currency |> get_currency_atom() |> supported?()
  end

  @spec supported?(currency_key :: atom) :: boolean
  def supported?(currency_key) do
    Map.has_key?(get_supported_currencies(), currency_key)
  end

  @spec fetch_exchange_rate_from_api(from_currency :: String.t(), to_currency :: String.t()) ::
          map()
  def fetch_exchange_rate_from_api(from_currency, to_currency),
    do: api_client().fetch(%{from_currency: from_currency, to_currency: to_currency})

  @spec get_currency_atom(currency_str :: String.t()) :: atom()
  def get_currency_atom(currency_str) do
    String.to_existing_atom(currency_str)
  rescue
    _e in ArgumentError -> nil
  end

  @spec get_supported_currencies() :: map()
  def get_supported_currencies do
    are_supported_currencies_values =
      Enum.all?(@supported_currencies, fn currency ->
        Map.has_key?(@currencies, currency)
      end)

    if not are_supported_currencies_values,
      do: raise("Invalid currency configuration")

    Enum.reduce(@supported_currencies, %{}, fn curr, acc ->
      Map.put(acc, curr, @currencies[curr])
    end)
  end

  defp api_client,
    do: Application.get_env(:payments_api, :alpha_vantage_api_client, AlphaVantageApiClient)
end
