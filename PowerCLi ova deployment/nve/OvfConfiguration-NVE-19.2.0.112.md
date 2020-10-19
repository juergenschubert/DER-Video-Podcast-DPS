PS C:\WINDOWS\system32\WindowsPowerShell\v1.0> $ovfConfig  
$ovfConfig.NetworkMapping.VM_Network  
$ovfConfig.NetworkMapping.VM_Network.Value = "VM Network"  
$ovfConfig.vami   
$ovfConfig.vami.NetWorker_Virtual_Edition  
$ovfConfig.vami.NetWorker_Virtual_Edition.ipv4  
$ovfConfig.vami.NetWorker_Virtual_Edition.ipv6  
$ovfConfig.vami.NetWorker_Virtual_Edition.gatewayv4  
$ovfConfig.vami.NetWorker_Virtual_Edition.gatewayv6  
$ovfConfig.vami.NetWorker_Virtual_Edition.DNS  
$ovfConfig.vami.NetWorker_Virtual_Edition.searchpaths  
$ovfConfig.vami.NetWorker_Virtual_Edition.FQDN  
$ovfConfig.vami.NetWorker_Virtual_Edition.NTP  
$ovfConfig.vami.NetWorker_Virtual_Edition.NVEtimezone  
$ovfConfig.vami.NetWorker_Virtual_Edition.DDIP  
$ovfConfig.vami.NetWorker_Virtual_Edition.DDBoostUseExistingUser  
$ovfConfig.vami.NetWorker_Virtual_Edition.DDBoostUsername  
$ovfConfig.vami.NetWorker_Virtual_Edition.vCenterFQDN  

====================================  
OvfConfiguration: NVE-19.2.0.112.ova  

   Properties:  
   -----------  
   NetworkMapping  
   vami  


Key                : NetworkMapping.VM Network  
Value              :  
DefaultValue       :    
OvfTypeDescription : string  
Description        : The virtual network the NVE's ethernet adapter will use  


NetWorker_Virtual_Edition : System.Object  


ipv4                   :
ipv6                   :
gatewayv4              :
gatewayv6              :
DNS                    :
searchpaths            :
FQDN                   :
NTP                    :
NVEtimezone            :
DDIP                   :
DDBoostUseExistingUser :
DDBoostUsername        :
vCenterFQDN            :
vCenterUsername        :


Key                : vami.ipv4.NetWorker_Virtual_Edition
Value              :
DefaultValue       :
OvfTypeDescription : string
Description        : If address is provided, the prefix length or mask should also be included (e.g 10.6.1.2/24 or 10.6.1.2/255.255.255.0). If
                     prefix/mask is not given, it will default to /24. Both IPv4 and IPv6 addresses may be given to configure a dual stack environment.


Key                : vami.ipv6.NetWorker_Virtual_Edition
Value              :
DefaultValue       :
OvfTypeDescription : string
Description        : If address is provided, the prefix length should also be included (e.g. 2000:10A::5/64). If prefix/mask is not given, it will
                     default to /64. Both IPv4 and IPv6 addresses may be given to configure a dual stack environment.


Key                : vami.gatewayv4.NetWorker_Virtual_Edition
Value              :
DefaultValue       :
OvfTypeDescription : string
Description        : IPv4 Default Gateway.


Key                : vami.gatewayv6.NetWorker_Virtual_Edition
Value              :
DefaultValue       :
OvfTypeDescription : string
Description        : IPv6 Default Gateway.


Key                : vami.DNS.NetWorker_Virtual_Edition
Value              :
DefaultValue       :
OvfTypeDescription : string
Description        : DNS server address(es) for this AVE, which can be a single address or comma seperated list of addresses (e.g. 10.10.10.25) - Both
                     IPv4 and IPv6 addresses may be specified. A maximum of 3 DNS server addresses are supported.


Key                : vami.searchpaths.NetWorker_Virtual_Edition
Value              :
DefaultValue       :
OvfTypeDescription : string
Description        : If specified, this comma seperated list of domain names will be added to the DNS search path. By default only the domain portion
                     of the AVE's hostname is added to the search path.


Key                : vami.FQDN.NetWorker_Virtual_Edition
Value              :
DefaultValue       :
OvfTypeDescription : string
Description        : The fully qualified domain name to be used as the hostname for this AVE. If not provided, the AVE will attempt to determine its
                     hostname from DNS using the IPv4 and/or IPv6 address(es) provided above. The FQDN can only include alphanumeric characters (a-z,
                     A-Z, and 0-9), hyphen (-), and period(.). Hyphen and periods are only allowed if surrounded by other characters.


Key                : vami.NTP.NetWorker_Virtual_Edition
Value              :
DefaultValue       :
OvfTypeDescription : string
Description        : NTP server address(es) which can be a single address or a comma seperated list of addresses. IPv4 and IPv6 addresses may be
                     provided. Hostnames are also allowed. If provided, VMware host timesync will be disabled and the NTP service, which is disabled
                     by default, will be enabled.


Key                : vami.NVEtimezone.NetWorker_Virtual_Edition
Value              :
DefaultValue       : UTC
OvfTypeDescription : string["UTC",         "Africa/Abidjan", "Africa/Accra", "Africa/Addis_Ababa", "Africa/Algiers", "Africa/Asmara", "Africa/Asmera",
                     "Africa/Bamako",          "Africa/Bangui", "Africa/Banjul", "Africa/Bissau", "Africa/Blantyre", "Africa/Brazzaville",
                     "Africa/Bujumbura", "Africa/Cairo",          "Africa/Casablanca", "Africa/Ceuta", "Africa/Conakry", "Africa/Dakar",
                     "Africa/Dar_es_Salaam", "Africa/Djibouti", "Africa/Douala",          "Africa/El_Aaiun", "Africa/Freetown", "Africa/Gaborone",
                     "Africa/Harare", "Africa/Johannesburg", "Africa/Kampala", "Africa/Khartoum",          "Africa/Kigali", "Africa/Kinshasa",
                     "Africa/Lagos", "Africa/Libreville", "Africa/Lome", "Africa/Luanda", "Africa/Lubumbashi", "Africa/Lusaka",
                     "Africa/Malabo", "Africa/Maputo", "Africa/Maseru", "Africa/Mbabane", "Africa/Mogadishu", "Africa/Monrovia", "Africa/Nairobi",
                     "Africa/Ndjamena",          "Africa/Niamey", "Africa/Nouakchott", "Africa/Ouagadougou", "Africa/Porto-Novo", "Africa/Sao_Tome",
                     "Africa/Timbuktu", "Africa/Tripoli",          "Africa/Tunis", "Africa/Windhoek", "America/Adak", "America/Anchorage",
                     "America/Anguilla", "America/Antigua", "America/Araguaina",          "America/Aruba", "America/Asuncion", "America/Barbados",
                     "America/Belem", "America/Belize", "America/Boa_Vista", "America/Bogota",          "America/Boise", "America/Buenos_Aires",
                     "America/Cambridge_Bay", "America/Cancun", "America/Caracas", "America/Catamarca", "America/Cayenne",          "America/Cayman",
                     "America/Chicago", "America/Chihuahua", "America/Cordoba", "America/Costa_Rica", "America/Cuiaba", "America/Curacao",
                     "America/Danmarkshavn", "America/Dawson", "America/Dawson_Creek", "America/Denver", "America/Detroit", "America/Dominica",
                     "America/Edmonton",          "America/Eirunepe", "America/El_Salvador", "America/Fortaleza", "America/Glace_Bay",
                     "America/Godthab", "America/Goose_Bay", "America/Grand_Turk",          "America/Grenada", "America/Guadeloupe",
                     "America/Guatemala", "America/Guayaquil", "America/Guyana", "America/Halifax", "America/Havana",          "America/Hermosillo",
                     "America/Indiana/Indianapolis", "America/Indiana/Knox", "America/Indiana/Marengo", "America/Indiana/Vevay",
                     "America/Indianapolis", "America/Inuvik", "America/Iqaluit", "America/Jamaica", "America/Jujuy", "America/Juneau",
                     "America/Kentucky/Louisville",          "America/Kentucky/Monticello", "America/La_Paz", "America/Lima", "America/Los_Angeles",
                     "America/Louisville", "America/Maceio", "America/Managua",          "America/Manaus", "America/Martinique", "America/Mazatlan",
                     "America/Mendoza", "America/Menominee", "America/Merida", "America/Mexico_City",          "America/Miquelon",
                     "America/Monterrey", "America/Montevideo", "America/Montreal", "America/Montserrat", "America/Nassau", "America/New_York",
                       "America/Nipigon", "America/Nome", "America/Noronha", "America/North_Dakota/Center", "America/Panama", "America/Pangnirtung",
                            "America/Paramaribo", "America/Phoenix", "America/Port-au-Prince", "America/Port_of_Spain", "America/Porto_Velho",
                     "America/Puerto_Rico",          "America/Rainy_River", "America/Rankin_Inlet", "America/Recife", "America/Regina",
                     "America/Rio_Branco", "America/Rosario", "America/Santiago",          "America/Santo_Domingo", "America/Sao_Paulo",
                     "America/Scoresbysund", "America/Shiprock", "America/St_Johns", "America/St_Kitts",          "America/St_Lucia",
                     "America/St_Thomas", "America/St_Vincent", "America/Swift_Current", "America/Tegucigalpa", "America/Thule",
                     "America/Thunder_Bay", "America/Tijuana", "America/Tortola", "America/Vancouver", "America/Whitehorse", "America/Winnipeg",
                     "America/Yakutat",          "America/Yellowknife", "Antarctica/Casey", "Antarctica/Davis", "Antarctica/DumontDUrville",
                     "Antarctica/Mawson", "Antarctica/McMurdo",          "Antarctica/Palmer", "Antarctica/South_Pole", "Antarctica/Syowa",
                     "Antarctica/Vostok", "Arctic/Longyearbyen", "Asia/Aden", "Asia/Almaty",          "Asia/Amman", "Asia/Anadyr", "Asia/Aqtau",
                     "Asia/Aqtobe", "Asia/Ashgabat", "Asia/Baghdad", "Asia/Bahrain", "Asia/Baku", "Asia/Bangkok",          "Asia/Beirut",
                     "Asia/Bishkek", "Asia/Brunei", "Asia/Choibalsan", "Asia/Chongqing", "Asia/Chungking", "Asia/Colombo", "Asia/Damascus",
                     "Asia/Dhaka", "Asia/Dili", "Asia/Dubai", "Asia/Dushanbe", "Asia/Gaza", "Asia/Harbin", "Asia/Hong_Kong", "Asia/Hovd",
                     "Asia/Irkutsk",          "Asia/Istanbul", "Asia/Jakarta", "Asia/Jayapura", "Asia/Jerusalem", "Asia/Kabul", "Asia/Kamchatka",
                     "Asia/Karachi", "Asia/Kashgar",          "Asia/Katmandu", "Asia/Kolkata", "Asia/Krasnoyarsk", "Asia/Kuala_Lumpur",
                     "Asia/Kuching", "Asia/Kuwait", "Asia/Macao", "Asia/Macau",          "Asia/Magadan", "Asia/Makassar", "Asia/Manila",
                     "Asia/Muscat", "Asia/Nicosia", "Asia/Novosibirsk", "Asia/Omsk", "Asia/Oral", "Asia/Phnom_Penh",          "Asia/Pontianak",
                     "Asia/Pyongyang", "Asia/Qatar", "Asia/Qyzylorda", "Asia/Rangoon", "Asia/Riyadh", "Asia/Saigon", "Asia/Sakhalin",
                     "Asia/Samarkand", "Asia/Seoul", "Asia/Shanghai", "Asia/Singapore", "Asia/Taipei", "Asia/Tashkent", "Asia/Tbilisi", "Asia/Tehran",
                     "Asia/Thimphu",          "Asia/Tokyo", "Asia/Ujung_Pandang", "Asia/Ulaanbaatar", "Asia/Urumqi", "Asia/Vientiane",
                     "Asia/Vladivostok", "Asia/Yakutsk",          "Asia/Yekaterinburg", "Asia/Yerevan", "Atlantic/Azores", "Atlantic/Bermuda",
                     "Atlantic/Canary", "Atlantic/Cape_Verde", "Atlantic/Faeroe",          "Atlantic/Faroe", "Atlantic/Jan_Mayen", "Atlantic/Madeira",
                     "Atlantic/Reykjavik", "Atlantic/South_Georgia", "Atlantic/St_Helena", "Atlantic/Stanley",          "Australia/ACT",
                     "Australia/Adelaide", "Australia/Brisbane", "Australia/Broken_Hill", "Australia/Darwin", "Australia/Eucla", "Australia/Hobart",
                            "Australia/Lindeman", "Australia/Lord_Howe", "Australia/Melbourne", "Australia/North", "Australia/NSW", "Australia/Perth",
                     "Australia/Queensland",          "Australia/South", "Australia/Sydney", "Australia/Tasmania", "Australia/Victoria",
                     "Australia/Yancowinna", "Europe/Amsterdam", "Europe/Andorra",          "Europe/Athens", "Europe/Belfast", "Europe/Belgrade",
                     "Europe/Berlin", "Europe/Bratislava", "Europe/Brussels", "Europe/Bucharest", "Europe/Budapest",          "Europe/Chisinau",
                     "Europe/Copenhagen", "Europe/Dublin", "Europe/Gibraltar", "Europe/Helsinki", "Europe/Istanbul", "Europe/Kaliningrad",
                     "Europe/Kiev",          "Europe/Lisbon", "Europe/Ljubljana", "Europe/London", "Europe/Luxembourg", "Europe/Madrid",
                     "Europe/Malta", "Europe/Minsk", "Europe/Monaco",          "Europe/Moscow", "Europe/Nicosia", "Europe/Oslo", "Europe/Paris",
                     "Europe/Prague", "Europe/Riga", "Europe/Rome", "Europe/Samara", "Europe/San_Marino",          "Europe/Sarajevo",
                     "Europe/Simferopol", "Europe/Skopje", "Europe/Sofia", "Europe/Stockholm", "Europe/Tallinn", "Europe/Tirane", "Europe/Uzhgorod",
                            "Europe/Vaduz", "Europe/Vatican", "Europe/Vienna", "Europe/Vilnius", "Europe/Warsaw", "Europe/Zagreb",
                     "Europe/Zaporozhye", "Europe/Zurich",          "Indian/Antananarivo", "Indian/Chagos", "Indian/Christmas", "Indian/Cocos",
                     "Indian/Comoro", "Indian/Kerguelen", "Indian/Mahe", "Indian/Maldives",          "Indian/Mauritius", "Indian/Mayotte",
                     "Indian/Reunion", "Pacific/Apia", "Pacific/Auckland", "Pacific/Chatham", "Pacific/Easter", "Pacific/Efate",
                     "Pacific/Enderbury", "Pacific/Fakaofo", "Pacific/Fiji", "Pacific/Funafuti", "Pacific/Galapagos", "Pacific/Gambier",
                     "Pacific/Guadalcanal", "Pacific/Guam",          "Pacific/Honolulu", "Pacific/Johnston", "Pacific/Kiritimati", "Pacific/Kosrae",
                     "Pacific/Kwajalein", "Pacific/Majuro", "Pacific/Marquesas", "Pacific/Midway",          "Pacific/Nauru", "Pacific/Niue",
                     "Pacific/Norfolk", "Pacific/Noumea", "Pacific/Pago_Pago", "Pacific/Palau", "Pacific/Pitcairn", "Pacific/Ponape",
                     "Pacific/Port_Moresby", "Pacific/Rarotonga", "Pacific/Saipan", "Pacific/Tahiti", "Pacific/Tarawa", "Pacific/Tongatapu",
                     "Pacific/Truk",          "Pacific/Wake", "Pacific/Wallis",      "Pacific/Yap"]
Description        : NVE timezone (Default: UTC)


Key                : vami.DDIP.NetWorker_Virtual_Edition
Value              :
DefaultValue       :
OvfTypeDescription : string
Description        : REQUIRED: IP address of working Data Domain.


Key                : vami.DDBoostUseExistingUser.NetWorker_Virtual_Edition
Value              :
DefaultValue       : No
OvfTypeDescription : string["Yes","No"]
Description        : Select Yes if there is already a DDBoost user name on Data Domain, otherwise select No to create a new DDBoost user (Default: No)


Key                : vami.DDBoostUsername.NetWorker_Virtual_Edition
Value              :
DefaultValue       :
OvfTypeDescription : string
Description        : REQUIRED: New DDBoost user with unique user name OR provide existing user with DDBoost role assigned.


Key                : vami.vCenterFQDN.NetWorker_Virtual_Edition
Value              :
DefaultValue       :
OvfTypeDescription : string
Description        : REQUIRED: IP address or FQDN of working vCenter.
