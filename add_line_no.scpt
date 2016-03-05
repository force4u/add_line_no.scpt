(*
add_line_no.scpt
20160303　初回作成　
20160305　ゼロサプレス処理変更
テキストデータに行番号を付加してその後にタブを挿入し
タブ区切りテキスト形式に変換した出力を
テキストエディタに表示します。
JeditXでテキストに行番号を発生させる
http://mottainaidtp.seesaa.net/article/434495744.html
の
アップルスクリプト版
*)


----設定項目
(*
１ならゼロサプレス有り
ソレ以外ならゼロサプレス無し
*)
property preZeroSup : 1


------------------------------------ ダブルクリックの始まり
on run
	------------プロンプトの文言改行が使えます\nを入れます
	set theWithPrompt to "テキストデーターにラインNO（行番号+タブ）を挿入します"
	------------ファイル選択ダイアログのデフォルトのディレクトリ
	tell application "Finder"
		---set theDefaultLocation to (path to desktop from user domain) as alias
		set theDefaultLocation to (container of (path to me)) as alias
	end tell
	------------Uniform Type Identifier指定
	set theFileTypeList to "public.plain-text,com.apple.traditional-mac-plain-text" as text
	------------↑のファイルタイプをリスト形式に整形する
	set AppleScript's text item delimiters to {","}
	set theFileTypeList to every text item of theFileTypeList
	------------ダイアログを出して選択されたファイルは「open」に渡す
	open (choose file default location theDefaultLocation ¬
		with prompt theWithPrompt ¬
		of type theFileTypeList ¬
		invisibles true ¬
		without multiple selections allowed and showing package contents)
end run


on open DropObj
	---ファイルのエイリアスを取得
	set theFileAlias to DropObj as alias
	------選択したファイルのUNIXパスを取得
	set theUnixPass to POSIX path of theFileAlias as text
	-----ファイルを読み込む
	set theData to (do shell script "cat '" & theUnixPass & "'") as «class utf8»
	---リスト用の区切り文字
	set AppleScript's text item delimiters to {"\r"}
	---読み込んだデータをリスト形式で格納
	set retListVal to (every text item of theData) as list
	---行毎データ初期化
	set theDataListLine to "" as text
	---アウトプットデータ初期化
	set theOutPut to "" as text
	-----読み込んだテキストの行数を数える
	set numListLine to count of retListVal
	-----行数カウンタ初期化
	set numLine to 1 as number
	----繰り返しの始まり
	repeat numListLine times
		---１つ読み込む
		set theDataListLine to (item numLine of retListVal) as text
		---ゼロサプレスの有無
		if preZeroSup is 1 then
			----ゼロサプレスあり
			set theZeroSupLineNo to doZeroSuppress(numLine, numListLine)
		else
			----ゼロサプレス無し
			set theZeroSupLineNo to numLine as text
		end if
		---出力テキスト整形
		set theOutPut to theOutPut & theZeroSupLineNo & "\t" & theDataListLine & "\r"
		---カウントアップ
		set numLine to (numLine + 1) as number
		---リピートのおわり
	end repeat
	---結果をテキストエディタで開く
	tell application "TextEdit" to launch
	tell application "TextEdit"
		make new document with properties {text:theOutPut}
	end tell
	tell application "TextEdit" to activate
end open




----ゼロサプレスのサブルーチン
#numValに処理する値
#numMaxValに最大数
#ゼロサプレス処理をします
to doZeroSuppress(numVal, numMaxVal)
	---戻り値の初期化
	set theSupZero to "" as text
	---最大数の桁数を数える
	set numCntTotal to (count of (numMaxVal as text)) as number
	---処理する値の桁数を数える
	set numCntN to (count of (numVal as text)) as number
	---差分を求める
	set numZeoCnt to ((numCntTotal) - (numCntN)) as number
	---桁数の差だけ処理する
	repeat numZeoCnt times
		---戻り値にゼロを追加
		set theSupZero to (theSupZero & "0") as text
	end repeat
	---戻り値を返す
	return (theSupZero & numVal) as text
end doZeroSuppress
