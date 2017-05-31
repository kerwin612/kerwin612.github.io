What you are trying to do is called a **sparse checkout**, and that feature was added in git 1.7.0 (Feb. 2012). The steps to do a sparse clone are as follows:
```
mkdir <repo>
cd <repo>
git init
git remote add -f origin <url>
```
This creates an empty repository with your remote, and fetches all objects but doesn't check them out. Then do:
```
git config core.sparseCheckout true
```
Now you need to define which `files/folders` you want to actually check out. This is done by listing them in **.git/info/sparse-checkout**, eg:
```
echo "some/dir/" >> .git/info/sparse-checkout
echo "another/sub/tree" >> .git/info/sparse-checkout
```
Last but not least, update your empty repo with the state from the remote:
```
git pull origin master
```
You will now have files "checked out" for *some/dir* and *another/sub/tree* on your file system (with those paths still), and no other paths present.

You might want to have a look at the [extended tutorial](http://jasonkarns.com/blog/subdirectory-checkouts-with-git-sparse-checkout/) and you should probably read the official [documentation for sparse checkout](http://schacon.github.com/git/git-read-tree.html#_sparse_checkout).