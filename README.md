# Bezpieczeństwo w Microsoft Azure - jak do niego podejść praktycznie?

Bezpieczeństwo to temat rzeka, może dotyczyć każdego aspektu rozwiązani w Azure, takiego jak tożsamosc, sieć, składowanie danych, [rozszerzenia do maszyn wirtualnych](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/features-windows),czy choćby model wdrażania zasobów (Deployment) czy przechowywania konfiguracji.

W tych czterach, krótkich lekcjach postaram się byś nieco "liznął" temat, którym głębiej zajmiejmy się juz w trakcie workshopu w ramach Cloudyna 2019.

## 1 RBAC, Role uzytkowników oraz Service Principal Name

Pierwszy bastion bezpieczeństwa w Twojej subskrypcji to tożsamość oraz uprawnienia nadane użytkownikom.
W Azure cały model uprawnień opiera się o koncepcję RBAC czyli Role Based Access Control, w której występują takie obiekty jak: * Zasób w Azure (Resource), do którego przypisujemy uprawnienie w kontekście uzytkownika lub grupy

* Rola czyli efektywnie zestaw uprawnień, jaki zostanie nadany
* Użytkownik lub Grupa Użytkownikow, którym rola zostanie nadana.

W Azure możemy też tworzyć własne role i ograniczać lub rozszerzać spektrum uprawnień w ramach obiektu. Czasem, stworzenie własnego zestawu ról to jedyna metoda by spełniać warunek speracji dostępu oraz podziału zadań pomiędzy rózne grupy / zespoły w organizacji. Nie wnikamy ;) czy aktualny model organizacji jest dopasowany do modelu chmurowego czy nie - to inne zagadanienie.

Zanim przytąpisz do działań, warto wyrównać wiedzę:

* [Azure RBAC Model](https://docs.microsoft.com/en-us/azure/role-based-access-control/overview)
* [Azure Custom Roles](https://docs.microsoft.com/en-us/azure/role-based-access-control/custom-roles)
* [Service Principal Namea](https://docs.microsoft.com/en-us/azure/role-based-access-control/custom-roles)

### Zadanie domowe 1

Mam dla Ciebie trzy zadania domowe do wykonania.

#### Subskrypcja

Upewnij się, ze masz dostep do subskrypcji w ramach której masz pelny dostep do Azure AD, ew. załóz testową subskrypcję.

#### Własna Role

Rzuć okiem na opis standardowych ról, dostępnych w ramach Azure AD [Azure Built-In Roles](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles). Zobacz jak łatwo wyeksportować dowolną rolę. Na tej podstawie, zbuduj własną rolę, która pozwoli na:

* uruchomienie maszyny
* zatrzymanie maszyny
* załozenie wpisu do supportu Azure
* zmianę wielkości maszyny

Ale tylko na to!

#### Weryfikacja SPN'ów

Jeśli jeszcze nie wiesz czym jest SPN, to proszę przeczytaj ten kawałek dokumentacji [Application and Servcice Principal Object](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals). SPN to potężna koncepcja, szczególnie wtedy jak automatyzujesz zadania przez Azure Automation, wykonujesz deployment za pomocą Azure DevOps czy konfgurujesz subskrypcję z poziomu Terraform. Dla narzędzi typu Ansible też się przyda więc zapoznaj się z nią dobrze.

Napisz kawałek skryptu (PowerShell, CLI), który pokaże wszystkie SPN w Twojej subskrypcji, pokaze jak długo są wazne i jaki poziom uprawnień w ramach subskrypcji posiadają. (dla tych, który robią zadanie na sbskrypcji testowej, to zadanie mozna pominac) Napisz mi równiez dwa słowa, czy Twoim zdaniem aktualny poziom uprawnień to ten, który faktycznie chciałeś przyznać i masz pod kontrolą. 

## 2. Azure Log Analytics

Azure Log Analytics [Azure Log Analytics](https://docs.microsoft.com/en-us/azure/azure-monitor/log-query/get-started-portal), z nazwy oraz opisu, sugeruje, że nadaje się dobrze jako usługa monitorowania środowiska. I faktycznie, Azure Log Analytics poprzez wiele wbudowanych rozszerzeń (solutions) i dodatki, które instalujesz na maszynach (extensions), moze być traktowane jako rozwiązanie monitoringu.
[Zobacz jakie dodatki możesz wykorzystać. Warto je znać zanim pójdziesz dalej](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/solutions-inventory).

Natomiast Azure Log Analytics może również pomóc w wykryciu i diagnozie potencjalnie sytuacji niebezpiecznych albo tych, które do tego doprowadzą. Temat szeroki ale dziś zajmiemy się jednym z rozszerzeń, które staje się powoli dostępn z poziomu kazdej maszyny wirtualnej.

Na początek poszukaj więcej informacji o rozszerzeniu Service Map, zastanów się do czego mógłbyś go użyc w swoim środowisku

### Zadanie domowe 2

W ramach zadania domowego pobawimy się w prosty scenariusz weryfikacji połączeń. **Najlepiej** jeśli dla tego zadania wydzielisz __oddzielną Resource Group__ i oddzielną sieć, w której będą tylko maszyny do testu.
Stwórz dwie maszyny wirtualne, jedna może być z systemem Ubuntu, druga z wybranym systemem Windows. Mogą to być małe maszyny np. z [serii B](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/b-series-burstable). Obie maszyny powinny do testu posiadać publiczny adres IP i otwarty tylko port SSH i RDP, odpowiedniej do typu maszyny. Stwórz usługę Azure Log Analytics, zainstaluj agenta tej usługi na obu maszynach, a także na obu z nich uruchom rozszerzenie Service Map. Poczekaj 24-48h (nie wyłączaj maszyn w tym czasie) i zobacz co ciekawego będzie raportował ten dodatek.

W ramach odpowiedzi na to zadanie, opisz, co ciekawego zauważyłeś. Poza prostymi wnioskami, poszukaj również korelacji pomiędzy zdarzeniami na samej maszynie a tym co pokazuje Service Map.

**Jak chcesz pójść krok dalej**, to ustaw zbieranie z maszyn podstawowych metryk wydajnościowych oraz logów systemowych, możesz też pójść jeszcze krok dalej i wykorzystać [**Change Tracking**](https://docs.microsoft.com/en-us/azure/automation/change-tracking). Twoja możliwość diagnozy zachowania maszyny będzie rosła.

## 3. Sieć w Azure, NSG, ASG oraz Service Tag w ramach sieci

Bezpieczeństwo konfiguracji sieci to jeden z pierwszych elementów, o które będzie pytał dział bezpieczeństwa kazdej organizacji. Patrzenie na bazpieczeństwo przez pryzmat tylko segmentacji sieci oraz budowanie sieci typu perimeter w dzisiejszym świecie to droga do nikąd. Natomiast, nadal kluczowe jest by rozumieć architekturę naszej sieci, w odpowiednich miejscach terminować ruch ale również mieć możliwość monitorinug. Dlatego, dobrze rozumieć elementy takie jak [NSG](https://docs.microsoft.com/en-us/azure/virtual-network/security-overview), [ASG](https://azure.microsoft.com/en-in/blog/applicationsecuritygroups/), [Service Tag](https://docs.microsoft.com/en-us/azure/virtual-network/security-overview#service-tags) pozwalają na wiele, choć samo ich wykorzystanie i upilnowanie w dużym środowisku moze być kłopotliwe. Jest coraz więcej dobrych rozwiązań (np. [Tuffin](https://www.tufin.com/supported-devices-and-platforms/microsoft-azure)), które pozwalają tym sterować i zarządzać centralnie (w ramach sieci on-premises oraz w chmurze w jednym miejscu).
Zajmijmy się jednak innym, dość prostym a kiedyś niełatwym do konfiguracji tematem - mamy dwa zadania, drugie z mała gwiazdką

### Zadania domowe 3

Za pomocą poznanych elementów ustaw sieć w ramach maszyny tak, by:

* maszyna miała swobodny dostęp do innych maszyn w ramach wybranej podsieci ([Subnet](https://docs.microsoft.com/en-us/office365/enterprise/designing-networking-for-microsoft-azure-iaas)), w której jest. W tym samym czasie, nie ma dostępu do maszyn w innych podsieciach.
* maszyna nie miała ruchu wychodzącego do Internetu, ale w tym samym czasie był poprawnie zarządzana przez portal i by ten poprawnie raportował jej status, pozwalał ją włączać i wyłączać
* maszyna mogła pobierać poprawki z Windows Update (jeśli wybrałeś maszynę opartą o Windows), pobierać poprawki z repozytoriów paczek (jeśli wybrałeś Linuxa)

W odpowiedzi napisz mi o swoich doświadczeniach, równiez wtedy, kiedy nie wszystko poszło dobrze. Czym byłaby nauka nowych elementów, gdyby wszystko działało tak, jak sobie to wprost wyobrażamy ;)

(**zadanie z "z gwiazdką"**) Jeśli masz ochotę, zastanów się, jakie usługi (z tych dostępnych w Azure), musiałbyś zaangazować i jak zaprojektowałbyś konfigurację, by ruch do Twojego konta składowania danych był filtrowany przez rodzaj Firewall'a. Ruch ten, dla uproszczenia może pochodzić z maszyny wirtualnej. 

## 4 Azure Security Center i Azure Sentinel

Jeśli szukasz jednego, kompleksowego podejscia do tematu bezpieczenstwa w ramach jednej lub wielu subskrypcji, musisz koniecznie przyjzec się tym dwum rozwiązaniom.

Rzuć okiem w dokumentację:

* [Azure Security Center](https://docs.microsoft.com/en-in/azure/security-center/security-center-intro)
* [Azure Sentinel](https://docs.microsoft.com/en-in/azure/sentinel/overview)

Security Center pokrywa analizę kilku obszarów m.in. tożsamość, sieć, konfigurację kont składowania danych, hardening systemów operacyjnych i więcej (np. analiza MFA).

Azure Sentinel natomiast ma oferować funkcjonalności chmurowego SIEM'a oraz SOAR czyli:

* pozwalać na zbieranie danych zdarzeń na temat bezpieczeństwa
* pozwalać na automatyzację działań, które mają przeciwdziałać zagrożniom, eliminować ataki

### Zadanie domowe 4

W ramach tego zadania chciałbym byś dobrze zrozumiał sens, która usługa i gdzie powinna zostać zaimplementowana i dlatego mam dla Ciebie trzy prośby:

* wypisz te funkcjonalności, które pokrywają się w obu produktach
* wypisz te funckjonalności, które są różne w kazdym z nich
* upewnij się, ze na pewno tak jest, najlepiej włączając w swojej subskrypcji obie funkcjonalności i sprawdzając co raportują

A na koniec, jeśli masz siłę (a przecież tak na pewno jest:)), spróbuj włączyć [Applicatio Gateway](https://docs.microsoft.com/en-us/azure/application-gateway/overview) w trybie [WAF](https://docs.microsoft.com/en-gb/azure/application-gateway/waf-overview) i zintegrować incydenty wykrywane przez WAF z Security Center lub Sentinel.

Daj znać co udało się osiągnąć, zachęcam do zrobienia wszystkich puntków.

## 5 Podsumowanie

Przez ostatnie 4 dni trochę "polizaliśmy lizaka przez szybę", patrząc na jakie aspekty mozesz zwrocić uwagę myśląc o konfiguracji bezpieczeństwa w swojej subskrypcji Azure.
Mam nadzieję, ze mimo wszystko poczułeś, ze przed Tobą duzo ciekawej pracy ale tez duza ilość punktów swobody do dalszej konfiguracji.

Jest wiele innych usług czy możliwości, kilka z nich poniżej:

* [Azure Firewall](https://docs.microsoft.com/en-gb/azure/firewall/) - Azure Firewall, który potrafi filtrować na poziomie adresów IP, nazw FQDN i rozszerza tym samym możliwości pokazane wyżej. Niektórzy wolą dedykowane rozwiązania firm trzecich.
* [NVA od firm trzecich](https://azuremarketplace.microsoft.com/fi/marketplace/apps/barracudanetworks.barracuda-ng-firewall?tab=Overview) - przykład dedykowanego rozwiązania, które jest dostarczane w postaci zestawu maszyn wirtualnych
* [Azure Disk Encryption](https://docs.microsoft.com/en-us/azure/security/azure-security-disk-encryption-overview) - możliwość szyfrowania dysków maszyn (zarówno dysku dla OS czy dysków pozostałych poza dyskiem TEMP) kluczem, który jest w [Azure KeyVault](https://docs.microsoft.com/en-in/azure/key-vault/key-vault-overview)
* [Azure SQL Data Masking](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-dynamic-data-masking-get-started) - możliwość maskowania danych, dla wybranego zestawu użytkowników (zarejstrowanych w ramach Azure SQL). Maskowanie polega na wskazaniu kolumn, które przy każdym zapytaniu będą zwracały zamaskowane dane. Wybór metody maskowania zalezy nieco od typu danych, jaki przechowujemy.
* [Azure Docker Registry with Aqua](https://www.aquasec.com/solutions/azure-container-security/) - skanowanie obrazów kontenerów i analiza potencjalnych podatności w ramach obrazu.

Jest jeszcze wiele, wiele innych. Rzuć okiem na mój stary wpis na [blogu](http://cloudarchitects.pl/2018/02/bezpieczenstwo-w-chmurze-wszyscy-pytaja-malo-kto-probuje-zglebic-temat/), wśród linków znajdziesz link do materiału przygotowanego przez Microsoft, w którym zebrano większość usług czy funkcji w ramach usług, które wpisują się w ten temat.

Jeśli działasz w chmurze, i chcesz budować tam realne systemy dla biznesu czy swoich klientów, to zdecydowanie czas zbudować swoją strategię bezpieczeństwa oraz, co chyba nawet wazniejsze, wybrać obszary , które będziesz regularnie audytował i monitorował. Największa luka w bezpieczeństwie najczęściej chowa się pomiędzy klawiaturą a krzesłem przy biurku ;)
**Zapraszam**, byś w ramach tej ostatniej lekcji, podzielił się swoimi spostrzeżeniami w tym obszarze. Każde, mile widziane!
