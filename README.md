# STOCKS APP FOR TINKOFF AND SIRIUS(2022)
---
Данная лабораторная работа направлена на разработку своего приложения которое запрашивает данные из интернета и отоброжает актуальную информцию бо акциях выбранных пользователем компании:
* название компании(Company name)
* обозначение бумаги на бирже (тикер): например, `AAPL` или `TCS`(Symbol)
* текущую цену(Price)
* изменение цены за период(Price change)
Также добавлены улучшения:
* Label реагирует цветом на изменение цены(повышение - green, понижение - red, неизменно - black)
* Добавлены логотипы компаний(загружаются с `https://storage.googleapis.com/iex/api/logos/{symbol}.png`
* Список акций динамичен и подгружает компании с `/stock/market/list/gainers`
* Добавлены ошибки при отсутствии интернета или "состовляющей" акции
* Переработан интерфейс
![Alt-текст](https://github.com/KreoManser/ios-sirius-22-tinkoff/blob/main/Preview.png "Preview")
