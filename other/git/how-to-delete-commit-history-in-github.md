# How to Delete Commit History in Github

Follow the below steps to complete this task.  
**Warning: This will remove your old commit history completely, You can’t recover it again.**

* **Create Orphan Branch** – Create a new orphan branch in git repository. The newly created branch will not show in ‘git branch’ command.

  ```text
  git checkout --orphan temp_branch
  ```

* **Add Files to Branch** – Now add all files to newly created branch and commit them using following commands.

  ```text
  git add -A
  git commit -am "the first commit"
  ```

* **Delete master Branch** – Now you can delete the master branch from your git repository.     

  ```text
  git branch -D master
  ```

* **Rename Current Branch** – After deleting the master branch, let’s rename newly created branch name to master.  

  ```text
  git branch -m master
  ```

* **Push Changes** – You have completed the changes to your local git repository. Finally, push your changes to the remote \(Github\) repository forcefully.  

  ```text
  git push -f origin master
  ```

Reference: [http://stackoverflow.com/questions/13716658/how-to-delete-all-commit-history-in-github](http://stackoverflow.com/questions/13716658/how-to-delete-all-commit-history-in-github) Reference: [https://tecadmin.net/delete-commit-history-in-github/](https://tecadmin.net/delete-commit-history-in-github/)

