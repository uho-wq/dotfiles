## dotfiles

### セットアップ

```sh
# パッケージのインストール
nix profile add '.#uho'

# nix-darwin + home-manager の適用
darwin-rebuild switch --flake '.#work'
```

### アップデート

```sh
nix run '.#update'
```
