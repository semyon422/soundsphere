# Добавление карт/музыки
Существует 4 способа добавления карт в soundsphere. Мы рекомендуем ознакомится со всеми способами.

soundsphere поддерживает следующие форматы карт:
- `.osu` - Карты из **osu!**
- `.qua` - Карты из **Quaver**
- `.sm` и `.ssc` - Карты из **StepMania** и **Etterna**
- `.bms`, `.bme`, `.bml` и `.pms` - Карты из **Lunatic Rave 2**, **beatoraja** и других **Beatmania** симуляторов
- `.ojn` - Карты из **o2jam**
- `.ksh` - Карты из **K-Shoot MANIA**
- `.sph` - Карты из **soundsphere**
- `.mid` и `.midi`

В самом конце страницы вы сможете найти ссылки на страницы загрузки карт.

## Добавление библиотеки карт из папки
Используя этот способ вы сможете указать путь до папки с картами на диске. Это самый лучший способ для добавления всех карт из других ритм игр установленных у вас на компьютере. Игра будет читать из той локации что вы указали без копирования файлов.

Для начала следует найти папку с картами, это может быть папка `Songs` из **osu!**, **Quaver** или **Etterna**, либо просто папка в которой находятся карты. Нас интересует папки с такой иерархией файлов (**osu!** и **Quaver**):
```
songs_folder/
├── song1/
│ ├── audio.mp3
│ ├── easy.osu
│ └── hard.osu
├── song2/
├── song3/
```

soundsphere так же поддерживает поиск карт из подпапок (**Etterna** и **StepMania**):
```
songs_folder/
├── pack1/
│ ├── song1/
│ │ ├── audio.mp3
│ │ └── chart.sm
│ ├── song2/
│ └── song3/
├── pack2/
├── pack3/
```

Для этого способа добавления карт потребуется корневая папка, в примерах выше это `songs_folder`, в случае с **osu!**, **Quaver** и **Etterna** это будет папка `Songs`.

1. Запустите soundsphere.
2. В нижней левой части экрана нажмите на иконку папки.
3. Для каждой папки необходимо создать свою локацию. Нажмите на кнопку `create location`
4. Справа в меню вы сможете переименовать локацию. Назовите её подходящим именем.
5. Далее необходимо перетащить папку с картами в окно игры. Таким образом игра получит путь до этой папки.
6. Нажмите `update` и дождитесь окончания добавления карт.

> После добавления карт вам потребуется нажать на кнопку `collections` в нижнем правом углу экрана и в том же месте нажать на кнопку `notecharts` для того чтобы обновить список карт. Это будет исправлено в новой версии UI. Это так же относится к следующему способу.

## Добавление новых карт в папку soundsphere
soundsphere имеет свою папку с картами в которую вы можете ложить карты любого формата. Эта папка находится по пути: `userdata/charts/` относительно корня игры. Добавлять новые карты следует в подпапки.

1. Перейдите в `userdata/charts/`
2. Создайте папку в которую вы будете класть карты. К примеру, путь получится таким: `userdata/charts/cool_songs/`.
3. В эту папку положите карты или паки (подпапки с картами).
4. Зайдите в игру и нажмите на иконку папки в нижнем левом углу экрана. 
5. Убедитесь что выбрана локация `soundsphere`. Нажмите на кнопку `update` в меню справа.

## Добавление `.osz` карт 
1. Перетащите `.osz` в окно игры.
2. Это всё.

## Загрузка карт из `osu!direct`
1. В меню выбора песен в нижнем правом углу нажмите на кнопку `direct`.
2. В этом меню вы сможете загрузить любую карту из osu!direct. В нём так же доступен поиск.
3. Выберете карту и нажмите на кнопку `download` в центре экрана. 
4. После окончания загрузки карт, статус которых вы можете увидеть в левой части экрана, нажмите на кнопку `recache downloads` в левой нижней части экрана.
5. Вернитесь в меню выбора песен нажав на кнопку `notecharts`.

## Ссылки на загрузку
> Мы не имеем никакого отношения к сайтам указанным ниже. Загружайте файлы с них на свой страх и риск.  

В этой секции мы подобрали сайты на которых легко загрузить карты.
- [**osu.ppy.sh**](https://osu.ppy.sh/beatmapsets) `.osu` формат. Регистрация обязательна.
- [**quavergame.com**](https://quavergame.com/maps) `.qua` формат. Регистрация через `Steam` обязательна
- [**etternaonline.com**](https://etternaonline.com/packs) `.sm` и `.ssc` формат. 
- [**search.stepmaniaonline.net**](https://search.stepmaniaonline.net/) `.sm` и `.ssc` формат.

## Ссылки на загруку BMS и PMS
Мы постарались собрать коллекцию из рабочих ссылок и попытались объяснить как загрузить карты из этих источников.

> *Некоторые* сайты используют HTTP соеденение, ни о какой безопасности при этом речи идти не может.  
> Убедительная просьба: **стойте на раздаче Torrent после загрузки!** С каждым годом скачать некоторые из архивов становится всё труднее и труднее из-за того что люди перестают их раздавать.

### [LUMINOUS](https://l-bms.space/)
[Первая часть (2.9GB)](https://slime.kr/downloads/luminous/Luminous%20PACK%201.0.1.rar) Прямая ссылка.  
[Вторая часть (2.7GB)](http://slime.kr/downloads/luminous/Pure%20White%20Full%20Package.rar) Прямая ссылка.

### [Toy Musical](https://tm2.toymusical.net/download.html)
[Первая часть (0.43GB)](https://tm2.toymusical.net/download/dl.php?dl=tm1) Прямая ссылка.  
[Вторая часть (0.51GB)](https://tm2.toymusical.net/download/dl.php?dl=tm2) Прямая ссылка.  
[Третья часть (2.0GB)](https://www.luzeria.net/tm3/update/tm3_n2_ver296_full.zip) Прямая ссылка.  
[Обновление третьей части (1.3GB)](https://www.luzeria.net/tm3/update/tm3_n2_ver299_sabun.zip) Прямая ссылка.  

### Korea BMS Starter Pack
[Polaris | Прямая ссылка (1.00GB)](http://musicgamelab.com:88/kbsp_polaris110.rar) Не качайте если боитесь HTTP соеденения.  
[Primrose | Прямая ссылка (1.3GB)](http://musicgamelab.com:88/KBSP_Primrose.rar) Не качайте если боитесь HTTP соеденения.  

### PABAT!
[2013 (2.1GB)](https://k-bms.com/party_pabat/event_file/PABAT_bms_event_package_total_62_bms.zip) Torrent. Внутри `.zip` находится `.torrent`. 16.04.2025 раздача активна.  
[2014 (1.6GB)](https://k-bms.com/party_pabat/event_file/PABAT_2014_seasons_60bms_package.zip) Torrent. Внутри `.zip` находится `.torrent`. 16.04.2025 раздача полумертва.  
[2016 (3.0GB)](https://drive.google.com/file/d/0B_JSxrtTvjwHMUg2YkxGWnd1N1k/view?resourcekey=0-upgGjVZqxAjEUavBdxWz1w) Google Drive  
[2018 (1.7GB)](https://drive.google.com/file/d/13Ll_2eRMIb-Gxe7ynlMqznf-vr2DmxIV/view) Google Drive  

### Be-Music West
[Google Drive (0.6GB)](https://drive.google.com/file/d/0B7f97zxWtVlnOU1xVV9HRXcwYzg/view)

### Mumeisen
[Mumeisen11 (1.3GB)](https://drive.usercontent.google.com/download?id=0BxcEoygd7bh-Y3FpaVdmdGhCQmM&export=download&authuser=0) Google Drive  
[Mumeisen15 (3.5GB)](https://drive.google.com/file/d/1p8_4UpilwmoresANu747w07M48X2rTUY/view) Google Drive  

### [The Big Sister BMS Project](https://bms.wrigglebug.xyz/)

### [bms.kyouko.moe](https://bms.kyouko.moe/)
Это огромная коллекция паков, есть возможность загрузить отдельные карты и возможность загрузить целые паки.  
Первым делом рекомендую ознакомится с [презентацией](https://docs.google.com/presentation/d/1j5Xwon8NR6rTvmYCvvnbhFyeP5SAL6NYHtlHhln8nSM/edit?slide=id.p#slide=id.p) где подробно описан лучший способ загрузки.  

Если нужно скачать отдельные карты, то перейдите по [этой ссылке](https://drive.google.com/drive/folders/1pJGq49KrF5St2Yfgp493oOKoDEIyZ6Hq) и далее перейдите в папку `BMS Library`.  

Паки на **15-80GB** находятся в `Combined Package/Previous Packages`.  
**Торрент** на кучу паков находится в `Combined Package/SP Insane+ (2022-11-04)`  

