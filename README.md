# 塗料在庫チェックリスト：公開とPC・iPhoneの自動同期

PCでは表、幅640px以下のスマートフォンでは塗料ごとのカードで表示します。iPhoneではSafariから公開URLを開いてください。

この一式は公開・同期の設定を行うための完成ファイルです。GitHubへのアップロード、Supabaseプロジェクトの作成、実際の端末間接続はまだ行っていません。

## 1. ファイルの役割

| ファイル | 用途 |
| --- | --- |
| `index.html` | 在庫表本体。GitHubにアップロードするファイルです。 |
| `.nojekyll` | GitHub Pagesでそのまま公開するための補助ファイル。なくても、このHTMLは通常公開できます。 |
| `supabase-setup.sql` | Supabaseの保存テーブルと、自分の在庫だけにアクセスできる権限を作る設定。 |
| `README.md` | この手順書。 |

GitHubに公開するために必須なのは `index.html` だけです。ZIPをアップロードするのではなく、ZIPを展開して中の `index.html` をアップロードしてください。

## 2. 現在の保存方法と変更点

従来の自動保存は `localStorage` です。ブラウザー・端末ごとの保存で、同じGitHub PagesのURLをPCとiPhoneで開いても自動では共有されません。[MDNの説明](https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage)

今回、Supabaseによる自動同期機能を追加しました。

- GitHub Pages：HTML画面の公開。
- Supabase：ログインと在庫データの保存。
- ブラウザー内保存：端末上の控えと、通信失敗時の未送信データの保持。

入力した個数と残量はHTMLファイルやGitHubのリポジトリには書き込まれません。同期を設定するとSupabaseの自分のアカウントに保存します。

## 3. 公開する前に在庫をバックアップ

1. 今まで使っていたHTMLを、今まで使っていたPCのブラウザーで開きます。
2. 「バックアップを保存」でJSONファイルを保存します。
3. このJSONファイルはGitHubにはアップロードせず、手元に残してください。

ローカルのHTMLからGitHub Pagesの公開URLに移ると保存場所が変わるため、公開ページでこのバックアップを読み込みます。ファイルを移しただけで入力内容が付いてくるわけではありません。

## 4. GitHub Pagesで公開

1. [GitHub](https://github.com/)にログインします。
2. 「New repository」で新しいリポジトリを作成します。名前は例として `paint-inventory` にします。
3. GitHub Freeの場合は **Public** を選びます。「Add a README file」を有効にして「Create repository」を押します。
4. リポジトリの「Code」画面で **Add file → Upload files** を選び、今回の **index.html** をアップロードします。アップロード先は一番上の階層です。フォルダーの中に入れないでください。
5. 「Commit changes」で保存します。`.nojekyll` もアップロードできる場合は、一緒に追加して構いません。
6. リポジトリの **Settings → Pages** を開きます。
7. **Build and deployment → Source** を **Deploy from a branch** にします。
8. **Branch** を **main**、フォルダーを **/(root)** にして **Save** を押します。
9. 公開処理が終わるとPages画面に公開URLが表示されます。そのURLをPC・iPhoneの両方で開きます。

公開URLの形は `https://ユーザー名.github.io/paint-inventory/` です。自分のPages画面に表示された実際のURLを使ってください。

GitHub Freeでの利用条件と設定手順：[サイトの作成](https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site)、[公開元の設定](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)

サイトの画面と製品一覧は公開されます。個人の在庫バックアップ、ログイン用パスワード、SupabaseのSecret keyはアップロードしないでください。

## 5. Supabaseで在庫の保存先を用意

### A. プロジェクトを作成

1. [Supabase](https://supabase.com/)にログインし、「New project」で在庫表用のプロジェクトを作成します。
2. プランと利用上限を確認して選択し、プロジェクトの準備が終わるまで待ちます。

Supabase管理画面に入るためのログインと、次で作る「在庫表用のログイン」は別です。

### B. 保存テーブルを作成

1. プロジェクトの **SQL Editor** で **New query** を開きます。
2. 同梱の `supabase-setup.sql` をテキストとして開き、内容をすべてコピーします。
3. SQL Editorに貼り付けて **Run** を実行します。
4. **Table Editor** に `paint_inventory` ができたことを確認します。

この設定は、各ユーザーが自分の在庫だけを読める・更新できるようにします。未ログインのアクセスには権限を与えません。[SupabaseのRow Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security)

Data APIを無効にしているプロジェクトでは、**Integrations → Data API** で有効にし、`public.paint_inventory` にアクセスできる状態にしてください。同梱SQLには必要な `authenticated` 権限も含まれています。[Data APIの説明](https://supabase.com/docs/guides/api/creating-routes)

### C. 在庫表用のユーザーを作成

1. Supabaseの **Authentication → Users** を開きます。
2. **Add user → Create new user** で、自分のメールアドレスと在庫表用のパスワードを登録します。
3. 自分用に管理画面から作るアカウントなので、作成画面に **Auto Confirm User** がある場合は有効にして、確認済みユーザーとして作成します。

この在庫表には新規登録画面を設けていません。作成した同じメールアドレス・パスワードでPCとiPhoneからログインします。パスワードを忘れた場合はSupabase管理画面からユーザーを管理してください。[Supabaseのユーザー管理](https://supabase.com/docs/guides/auth/users)

### D. 接続情報を確認

プロジェクトの **Connect** 画面などで、以下の2つを確認します。

- **Project URL**：`https://xxxxx.supabase.co` の形式。
- **Publishable key**：`sb_publishable_` で始まるキー。**Settings → API Keys** にもあります。旧形式の `anon` キーでも利用できます。

在庫表の入力欄に使うのはブラウザー向けの公開キーです。**Secret key / service_roleキーは使いません。** アプリでもこれらを受け付けないようにしています。[キーの違いと確認場所](https://supabase.com/docs/guides/getting-started/api-keys)

## 6. PCで最初の同期を開始

1. GitHub Pagesの公開URLをPCで開きます。
2. 「バックアップを読み込む」で、手順3で保存した在庫JSONを読み込みます。
3. 一覧の下にある **PC・iPhone間の自動同期** を開きます。
4. Project URL、Publishable key、在庫表用のメールアドレス・パスワードを入力します。
5. **ログインして同期** を押します。
6. クラウドが空の場合は、端末の在庫を送信する確認が出ます。送信して同期を始めます。
7. **同期済み** の表示を確認します。

ログイン前の在庫は端末内に移行前バックアップとして残します。「移行前の在庫を復元」から戻せます。通常のJSONバックアップも残しておいてください。

## 7. iPhoneで同期

1. **Safariで同じGitHub Pagesの公開URL** を開きます。ファイルアプリのHTMLプレビューではなく、公開ページを使います。
2. **PC・iPhone間の自動同期** を開き、PCと同じProject URL・Publishable key・メールアドレス・パスワードでログインします。
3. クラウドに保存された在庫が表示されます。通常はiPhoneに古いJSONを読み込む必要はありません。
4. iPhoneで1色だけ個数を変更して「同期済み」になるのを確認し、PCで「今すぐ同期」を押して反映を確認します。逆方向も1色で確認してください。

スマートフォンでは幅に応じてカード表示になり、個数入力には数字キーボードを指定しています。分類の小タブは左右にスワイプできます。

## 8. 同期の動きと使い方

- 入力後、約1秒で変更した塗料だけを送信します。
- 別端末の更新は、ページ表示中に約20秒ごとに読み込みます。Safariに戻ったときにも読み込みます。「今すぐ同期」でも更新できます。
- ページを閉じている間はブラウザー側の処理は動きません。再度開くと同期を再開します。
- 同じ色をPCとiPhoneで同時に変更した場合は、後からサーバーに届いた内容が優先されます。異なる色の編集は塗料ごとに保存します。
- 通信失敗時は未送信の入力を端末に保持し、接続が戻ると再試行します。同じアカウントでログインしていることを確認してください。
- ログイン状態はブラウザーに保持します。プライベートブラウズやサイトデータの削除をすると、再ログインが必要になったり、未送信データが消えたりします。
- 接続先の設定は各ブラウザーで一度ずつ入力します。HTMLを編集してパスワード等を書き込む必要はありません。
- 定期的なJSONバックアップもそのまま使えます。同期中にバックアップを読み込むと、読み込んだ内容の変更もクラウドに送信します。

## 9. HTMLを更新するとき

同じリポジトリの `index.html` を新しいものに差し替えてコミットします。Pagesの公開設定はそのままで構いません。公開URLを変えず、PCとiPhoneのページを再読み込みしてください。

## 10. 確認済みの範囲

製品815項目・分類25種の切り替え、従来の保存とバックアップ、2端末を模した同期、送信中の追加編集、通信失敗・再読込後の再送、アカウントの分離をローカルの模擬サービスで確認しました。

実際のSupabaseへの接続、GitHub Pagesの公開、iPhone実機での表示は未確認です。上の手順で設定し、手順7の相互反映を確認すると利用開始できます。
