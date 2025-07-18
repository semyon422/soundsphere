> このページはAIによって翻訳されました!!! 混乱を引き起こすような誤りが含まれている可能性がありますが、それでもここに説明されている内容は理解できると思います。ロボットに怯える場合は、オリジナルの英語ページを読んでください!

# 曲の追加
<%= brand.name %> に曲を追加する方法は4つあります。これらすべての方法に慣れておくことをおすすめします。

<%= brand.name %> は以下の曲フォーマットをサポートしています:
- `.osu` - **osu!** からのビートマップ
- `.qua` - **Quaver** からの曲
- `.sm` と `.ssc` - **StepMania** と **Etterna** からの曲
- `.bms`, `.bme`, `.bml` と `.pms` - **Lunatic Rave 2**、**beatoraja** およびその他の **Beatmania** シミュレーターからの曲
- `.ojn` - **o2jam** からの曲
- `.ksh` - **K-Shoot MANIA** からの曲
- `.sph` - **<%= brand.name %>** からの曲
- `.mid` と `.midi`

ページの最後には曲のダウンロードページへのリンクがあります。

## フォルダから曲ライブラリを追加
この方法を使用すると、ディスク上の曲が保存されているフォルダのパスを指定できます。これにより、コンピュータにインストールされている他のリズムゲームのすべての曲を追加することができます。ゲームは指定した場所からファイルを読み込み、ファイルをコピーすることなく使用できます。

まず、曲が保存されているフォルダを見つけます。これは **osu!**、**Quaver** または **Etterna** の `Songs` フォルダである可能性があります。また、その他のフォルダでも構いません。私たちは次のファイル階層を持つフォルダに興味があります（**osu!** と **Quaver**）:
```
songs_folder/
├── song1/
│ ├── audio.mp3
│ ├── easy.osu
│ └── hard.osu
├── song2/
├── song3/
```

<%= brand.name %> はサブフォルダから曲を検索することもサポートしています（**Etterna** と **StepMania**）:
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

この曲の追加方法にはルートフォルダが必要です。上記の例では `songs_folder` がルートフォルダです。**osu!**、**Quaver** および **Etterna** の場合は `Songs` フォルダになります。

1. <%= brand.name %> を起動します。
2. 画面の左下にあるフォルダアイコンをクリックします。
3. 各フォルダに対して異なる場所を作成する必要があります。`create location` ボタンをクリックします。
4. メニューの右側で場所の名前を変更できます。適切な名前を付けます。
5. 次に、曲が保存されているフォルダをゲームウィンドウにドラッグします。これにより、ゲームはそのフォルダのパスを取得します。
6. `update` ボタンをクリックし、曲が追加されるのを待ちます。

> 曲を追加した後、画面右下隅にある `collections` ボタンをクリックし、同じ場所で `notecharts` ボタンをクリックして曲のリストを更新する必要があります。これは新しい UI バージョンで修正されます。次の方法も同様です。

## <%= brand.name %> フォルダに新しい曲を追加
<%= brand.name %> には独自の曲フォルダがあり、任意のフォーマットの曲を追加できます。このフォルダはゲームのルートからの相対パス `userdata/charts/` にあります。新しい曲はサブフォルダに追加します。

1. `userdata/charts/` に移動します。
2. 曲を保存するためのフォルダを作成します。例えば、パスは次のようになります: `userdata/charts/cool_songs/`。
3. このフォルダに曲やパック（曲が保存されているサブフォルダ）を追加します。
4. ゲームに移動し、画面左下隅にあるフォルダアイコンをクリックします。
5. `<%= brand.location_name %>` 場所が選択されていることを確認し、右側のメニューにある `update` ボタンをクリックします。

## `.osz` 曲の追加
1. `.osz` ファイルをゲームウィンドウにドラッグします。
2. これで完了です。

## ダウンロードリンク
> 以下のサイトとは関係ありません。これらのサイトからファイルをダウンロードする際は自己責任で行ってください。

このセクションでは、簡単に曲をダウンロードできるサイトを選択しました。
- [**osu.ppy.sh**](https://osu.ppy.sh/beatmapsets) `.osu` フォーマット。登録が必要です。
- [**quavergame.com**](https://quavergame.com/maps) `.qua` フォーマット。`Steam` での登録が必要です。
- [**etternaonline.com**](https://etternaonline.com/packs) `.sm` と `.ssc` フォーマット。
- [**search.stepmaniaonline.net**](https://search.stepmaniaonline.net/) `.sm` と `.ssc` フォーマット。
