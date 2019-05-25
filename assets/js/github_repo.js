function get_github(owner, repo) {

  return new Promise((resolve, reject) => {
  
    const xhr = new XMLHttpRequest();
    var url = "https://api.github.com/repos/" + owner + "/"+ repo;
    xhr.open('GET', url);

    xhr.onload = function() {
      if (xhr.status >= 200 && xhr.status < 400) {
        resolve(JSON.parse(xhr.responseText));
      } else {
        resolve(xhr.responseText);
      }
    };
    xhr.onerror = () => reject(xhr.statusText);
    xhr.send();
  });
}

function add_repo(owner, repo, id, cl) {
  get_github(owner, repo).then(data => {
    var iDiv = document.createElement('div');
    iDiv.setAttribute('class', 'column');
    iDiv.innerHTML = "<li class = '" + cl + "'><b><a href ='" + data.html_url + "'>" + data.name + "</a></b> <br><span class = 'page__meta'> " + data.description + "</span><br><a href='" + data.html_url + "'><button class = 'button'><i class='fas fa-star'></i> " + data.stargazers_count + "</button></a>" + "<a href='" + data.html_url + "'><button class = 'button'><i class= 'fas fa-code-branch'></i> " + data.forks_count + "</button></a>"
    var target = document.getElementById(id)
    target.appendChild(iDiv)
})
}