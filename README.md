
copy agda-input.el from agda's emacs-mode

```
git clone https://github.com/agda/agda.git
cp agda/src/data/emacs-mode/agda-input.el .
```
I wrote the `extract-agda-input` with the help of an llm.

```
nix-shell -p emacs
emacs --batch -l extract-agda-input.el
```
