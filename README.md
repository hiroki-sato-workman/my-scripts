# my-scripts

### scripts

| スクリプト                     | 説明                                                       |
| ------------------------------ | ---------------------------------------------------------- |
| [commit.sh](scripts/commit.sh) | git 用のコミットメッセージを作成する                       |
| [switch.sh](scripts/switch.sh) | ベースブランチから特定のフォーマットで新しいブランチを作る |

## エイリアス設定方法

エイリアスを設定

```bash
echo -e "alias commit='~/projects/my-scripts/scripts/commit.sh'" >> ~/.zshrc
echo -e "alias switch='~/projects/my-scripts/scripts/switch.sh'" >> ~/.zshrc
```

設定を反映

```bash
source ~/.zshrc
```
