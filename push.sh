#/bin/sh
cp -rnf /home/agou-ops/myWeb/beforeWork/* /home/agou-ops/myWeb/docs/source/myStudyNote
git add -A
git commit -m "rebuilding site $(date)"
git push 
