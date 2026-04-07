## dotfiles

```
go install github.com/rhysd/dotfiles@latest
```

### clone 
```
dotfiles clone kazu-gor
```

### link
```
dotfiles link .
```

### clean
```
dotfiles clean .
```

## nix

初期

```sh
nix profile add '.#uho'
```

アップデート

```sh
nix run profile '.#update'
```
