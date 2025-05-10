#!/bin/bash

# color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
NC='\033[0m'


# 許可された type と scope の定義
types=(
  "feat:     ユーザー向けの新機能であり、ビルドスクリプトの新機能ではない"
  "fix:      ビルドスクリプトの修正ではなく、ユーザーのためのバグ修正"
  "docs:     ドキュメントの変更"
  "style:    書式設定、セミコロンの欠落など"
  "refactor: プロダクションコードのリファクタリング"
  "test:     不足しているテストの追加、テストのリファクタリング"
  "chore:    gruntタスクの更新など、プロダクションコードの変更なし"
  "update:   node module をアップデート"
  "spike:    spike コミット（コメントあり）"
  "spike-no-comment: spike コミット（コメントなし）"
)

# コンソールの履歴を削除
clear

# ステージされた変更がなければキャンセル
if [ -z "$(git diff --cached --shortstat 2> /dev/null)" ]; then
  printf "${RED}コミットする変更がありません${NC}\n"
  exit 1
fi

# ステージされた変更の表示
echo "ステージされた変更:"
printf "${GREEN}$(git diff --name-only --cached)${NC}\n"

# type の入力
PS3="Commit Type: "
select typeKey in "${types[@]}"; do
  if [[ -n "$typeKey" ]]; then
    type=$(echo $typeKey | cut -d: -f1)
    printf "${BLUE}Selected Type: $(echo $type)${NC}\n"
    break;
  else
    printf "${RED}Invalid selection${NC}\n"
    exit 1
  fi
done

# subject の入力(spike コミットのコメント無しの場合は省略)
if [ "$type" != "spike-no-comment" ]; then
  while true; do
    echo "Commit Subject:"
    read -e subject
    #
    if [ -z "$subject" ]; then
      printf "${YELLOW}コミットメッセージは空欄にできません。再度入力してください。${NC}\n"
    else
      break
    fi
  done
else
  subject=""
fi

# コミットメッセージの生成
message="$type"
if [[ -n "$scope" ]]; then
  message+="($scope)"
fi
if [[ -n "$subject" ]]; then
  message+=": $subject"
fi

# pre-commit のチェックをスキップするかどうか
verify=""
if [[ "$type" == "spike" || "$type" == "spike-no-comment" ]]; then
  # spike コミットの場合はチェックをスキップ
  verify="--no-verify"
else
  read -e -p "コミット前のチェックを省略しますか？ (初期値: 省略しない) [y/n] " answer
  if [[ "$answer" = "y" ]]; then
      verify="--no-verify"
  fi
fi

# 最終的なコミットメッセージをコンソールに表示（pre-commit のチェックに失敗したとき用）
printf "${BLUE}Commit Message --------------------------------------------${NC}\n"
printf "git commit -m '$message' $verify\n"
printf "${BLUE}-----------------------------------------------------------${NC}\n"

# コミットの実行
echo -e $message | git commit -F - $verify
