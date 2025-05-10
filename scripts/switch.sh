#!/bin/bash

# ベースブランチ
baseBranch="develop"
stgfixBaseBranch="stage"
hotfixBaseBranch="master"

# type の定義
types=(
  "feature:  機能追加"
  "bugfix:   ビルドスクリプトの修正ではなく、ユーザーのためのバグ修正"
  "stgfix:   staging 環境リリース後に見つかった不具合で、staging 環境にリリースをする場合"
  "hotfix:   影響が大きく hotfix リリースする場合"
  "test:     不足しているテストの追加、テストのリファクタリング"
  "chore:    gruntタスクの更新など、プロダクションコードの変更なし"
  "update:   node module をアップデート"
)

# 現在のブランチを表示
printf "\033[32mベースブランチ\033[0m\n"
echo $baseBranch
# 現在のブランチを表示
printf "\033[32m現在のブランチ\033[0m\n"
git rev-parse --abbrev-ref HEAD
# 現在の変更を表示
printf "\033[32m現在の変更\033[0m\n"
changed_files=$(git status -s | awk '{print $2}')
if [ -z "$changed_files" ]; then
  echo "変更無し"
else
  echo "$changed_files"
fi


read -e -p "ブランチを作成しますか？ [y/n] " answer
if [[ "$answer" = "n" ]]; then
  printf "\033[33mブランチ作成をキャンセルしました\033[0m\n"
  exit
fi

# type の入力
PS3="Branch Type: "
select typeKey in "${types[@]}"; do
  if [[ -n "$typeKey" ]]; then
    type=$(echo $typeKey | cut -d: -f1)
    printf "\033[34mSelected Type: $(echo $type)\033[0m\n"
    break;
  else
    printf "\033[31mInvalid selection\033[0m\n"
    exit 1
  fi
done

# チケットIDを入力
while true; do
  echo "チケットIDまたはURLを入力"
  read -e enterdeTicketId
  #
  if [ -z "$enterdeTicketId" ]; then
    printf "\033[33mチケットIDまたはURLを入力してください\033[0m\n"
  else
    break
  fi
done

targetBaseBranch=""
# ベースブランチを設定
if [ "$type" = "stgfix" ]; then
  targetBaseBranch=$stgfixBaseBranch
elif [ "$type" = "hotfix" ]; then
  targetBaseBranch=$hotfixBaseBranch
else
  targetBaseBranch=$baseBranch
fi

# TODO: あとで消す
read -e -p "ベースブランチは ${targetBaseBranch} です。 pull しても良いですか？ [y/n] " answer
if [[ "$answer" = "n" ]]; then
    printf "\033[33mブランチ作成をキャンセルしました\033[0m\n"
    exit
fi

# ベースブランチを pull
git switch $targetBaseBranch
git pull

# ブランチを作成
git switch -c "${type}/${enterdeTicketId##*/}"

# 現在のブランチを表示
printf "\033[32mブランチを作成しました\033[0m\n"
git branch
