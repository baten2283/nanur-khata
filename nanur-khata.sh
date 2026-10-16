#!/usr/bin/env bash
# Nanu's Recipe Book - Git assignment, all 5 chapters
# Usage:
#   1. Create an EMPTY repo on GitHub (no README), copy its URL.
#   2. Edit MY_NAME, MY_EMAIL, REMOTE_URL below.
#   3. Run: bash nanur-khata.sh
# Take screenshots of the terminal output as you go (run it in chunks if you like).

set -e

MY_NAME="Md Ruman"
MY_EMAIL="baten22583@gmail.com"
REMOTE_URL="https://github.com/baten2283/nanur-khata.git"

say() { echo; echo "================ $* ================"; }

# ---------------------------------------------------------------
say "CHAPTER 1: The First Recipe"
# ---------------------------------------------------------------
git config --global user.name  "$MY_NAME"
git config --global user.email "$MY_EMAIL"
git config --global init.defaultBranch main
git config --global pull.rebase false

mkdir nanur-khata && cd nanur-khata
git init

cat > bhapa-pitha.md <<'EOF'
# Bhapa Pitha

## Ingredients
- 2 cups rice flour
- 2 cups gur (date palm jaggery)
- 1 cup grated coconut

## Method
Mix flour with warm water, fill with coconut and gur, steam for 10 minutes.
EOF

git status
git add bhapa-pitha.md
git status

# Task C: Nanu corrects the gur quantity
sed -i 's/2 cups gur/1.5 cups gur/' bhapa-pitha.md
echo "--- git diff (working dir vs staged: shows the gur change) ---"
git diff
echo "--- git diff --staged (staged vs last commit: shows the whole new file) ---"
git diff --staged

git add bhapa-pitha.md
git commit -m "Add bhapa pitha recipe with corrected gur quantity (1.5 cups)"

# Task E: accidentally staged bazar-list.txt
echo "chal, gur, narkel, elach" > bazar-list.txt
git add bazar-list.txt
git status
git reset bazar-list.txt
git status

# ---------------------------------------------------------------
say "CHAPTER 2: The Secret Spice"
# ---------------------------------------------------------------
echo "SECRET: nanu's special masala blend" > secret-masala.txt
touch notes.tmp cache.tmp
mkdir draft
echo "half written idea" > draft/idea.md

cat > .gitignore <<'EOF'
# Nanu's secret spice must never leave this kitchen
secret-masala.txt

# temporary files
*.tmp

# unfinished drafts
draft/
EOF

git status          # secret-masala.txt, *.tmp, draft/ must NOT appear
git check-ignore -v secret-masala.txt notes.tmp draft/idea.md

git add .gitignore bazar-list.txt
git commit -m "Add .gitignore to protect secret masala, tmp files and drafts"

# ---------------------------------------------------------------
say "CHAPTER 3: The Eid Special"
# ---------------------------------------------------------------
git branch eid-special
git checkout eid-special

cat > biryani.md <<'EOF'
# Eid Biryani

## Ingredients
- 1 kg basmati rice
- 1 kg mutton
- 2 cups yogurt
- Whole spices

## Method
Marinate mutton, layer with rice, cook on dum for 45 minutes.
EOF
git add biryani.md
git commit -m "Add Eid biryani recipe"

cat > shemai.md <<'EOF'
# Shemai

## Ingredients
- 200 g vermicelli
- 1 litre milk
- Sugar, ghee, raisins

## Method
Fry vermicelli in ghee, add milk and sugar, simmer until thick.
EOF
git add shemai.md
git commit -m "Add shemai recipe"

git checkout main
echo "--- on main, before merge ---"
ls
git merge eid-special
echo "--- on main, after merge ---"
ls
git log --oneline --graph --all

# Challenge: create a merge conflict on purpose
git checkout -b conflict-test
sed -i 's/Whole spices/Whole spices: cardamom, cinnamon, cloves/' biryani.md
git commit -am "Biryani: list the whole spices in detail"

git checkout main
sed -i 's/Whole spices/Whole spices and saffron milk/' biryani.md
git commit -am "Biryani: add saffron milk to the ingredients"

git merge conflict-test || true     # CONFLICT happens here
git status
echo "--- the conflicted file ---"
cat biryani.md

# Resolve: keep both ideas in one line
sed -i '/^<<<<<<< /d;/^=======$/d;/^>>>>>>> /d' biryani.md
sed -i '/Whole spices and saffron milk/d' biryani.md
sed -i 's/Whole spices: cardamom, cinnamon, cloves/Whole spices: cardamom, cinnamon, cloves, plus saffron milk/' biryani.md
echo "--- resolved file ---"
cat biryani.md
git add biryani.md
git commit -m "Merge conflict-test: combine spice list with saffron milk"
git log --oneline --graph --all

# ---------------------------------------------------------------
say "CHAPTER 4: Mitu Joins In"
# ---------------------------------------------------------------
git remote add origin "$REMOTE_URL"
git remote -v
git push -u origin main
git push origin eid-special

# Task B: play Mitu in another folder
cd ..
git clone "$REMOTE_URL" mitu-nanur-khata
cd mitu-nanur-khata
git config user.name  "Mitu"
git config user.email "mitu@example.com"
cat > chittagong-mezban.md <<'EOF'
# Chattogram Mezban Beef

Slow-cooked with mustard oil, black pepper and lots of onion.
Served at weddings, always with plain rice.
EOF
git add chittagong-mezban.md
git commit -m "Mitu: add Chattogram mezban beef recipe"
git push origin main

# Task C: back in my folder: fetch, then merge
cd ../nanur-khata
git fetch origin
git log --oneline main..origin/main      # what is new on the remote
git merge origin/main
ls

# Task D: Mitu pushes again, this time I use git pull
cd ../mitu-nanur-khata
cat >> chittagong-mezban.md <<'EOF'

Tip from Mitu: rest the meat for 30 minutes before serving.
EOF
git commit -am "Mitu: add resting tip to mezban recipe"
git push origin main

cd ../nanur-khata
git pull origin main
git log --oneline -5

# ---------------------------------------------------------------
say "CHAPTER 5: Half-Cooked Halua and Time Travel"
# ---------------------------------------------------------------
# Task A: halua work in progress, then Nanu calls about cardamom
cat > halua.md <<'EOF'
# Halua

## Ingredients
- 1 cup semolina
- 1 cup sugar
- (still writing...)
EOF
git add halua.md                     # stash only saves tracked/staged files
git stash
git status
git stash list

sed -i 's/Whole spices: cardamom/Whole spices: green cardamom (elach)/' biryani.md
git commit -am "Fix biryani: add the forgotten green cardamom"

git stash pop
git add halua.md
git commit -m "Add halua recipe"

# Task B: organise into folders, delete an old recipe
mkdir -p recipes/pitha recipes/eid recipes/mezban
echo "# Old Khichuri (not used any more)" > old-khichuri.md
git add old-khichuri.md
git commit -m "Add old khichuri draft"

git mv bhapa-pitha.md recipes/pitha/
git mv biryani.md shemai.md halua.md recipes/eid/
git mv chittagong-mezban.md recipes/mezban/
git rm old-khichuri.md
git commit -m "Organise recipes into folders and remove old khichuri"
git log --stat -M -3

# Task C: git show
SHA=$(git log --format=%h --grep="forgotten green cardamom")
git show "$SHA"

# Task D: reset --hard, but ONLY on a throw-away test branch
git checkout -b test-reset
OLDER=$(git log --format=%h --grep="Add halua recipe")
echo "--- before reset ---"; git log --oneline -4
git reset --hard "$OLDER"
echo "--- after reset (folders and the removed file are gone, files are back at old paths) ---"
git log --oneline -3
ls
git reflog -5
git checkout main
git branch -D test-reset || true

git push origin main

# ---------------------------------------------------------------
say "FINAL CHECKS"
# ---------------------------------------------------------------
echo "Commits on main: $(git rev-list --count main)"
echo "Branches:"; git branch -a
echo "secret-masala.txt tracked?  ->  $(git ls-files | grep -c secret-masala || true) (must be 0)"
git log --oneline --graph --all
