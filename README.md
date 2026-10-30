# softcover-docker

[softcover](https://github.com/softcover/softcover) で電子書籍（PDF・EPUB・HTML）を作るための Docker イメージです。

公式の [softcover/softcover](https://hub.docker.com/r/softcover/softcover) イメージ（Debian 9・TeX Live 2016・Ruby 2.6）に、Ruby 3.3 を足しています。
OS と TeX は元のイメージのままなので、作られる電子書籍は元のイメージで作ったものと同じになります。

## 使い方

```sh
docker run --rm -v "$PWD:/work" -w /work ghcr.io/yasslab/softcover-docker:ruby3.3@sha256:<digest> \
  bash -c "bundle install && bundle exec softcover build:pdf"
```

タグ `ruby3.3` は、このリポジトリの master が変わるたびに組み直されます。
出力を変えたくない場合は、上の例のように digest で固定してください。

## softcover 1.6 系の gem を Ruby 3.3 で使う時の注意

- 古い C 拡張（curb・thin・json など）は、Ruby 3.3 が付けるコンパイラの設定では組めません。このイメージでは `BUNDLE_BUILD__*` の環境変数で組めるようにしています。
- nokogiri 1.10 は、イメージに入っている libxml2 を使って組みます（`NOKOGIRI_USE_SYSTEM_LIBRARIES=1`）。
- curb は 0.9 系に固定してください。1.0 系は Debian 9 の libcurl では組めません。
- Ruby 3.3 で標準から外れた `racc` を、Gemfile に足してください（nokogiri 1.10 が読みます）。
