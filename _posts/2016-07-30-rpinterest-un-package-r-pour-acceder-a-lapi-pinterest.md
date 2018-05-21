---
title: "rpinterest : un package R pour accéder à l'API Pinterest"

post_date: 2016-07-30 20:17:45
layout: single
permalink: /rpinterest-un-package-r-pour-acceder-a-lapi-pinterest/
published: true
categories : r-blog-fr
tags: [r, package, api]
---
## Accéder aux boards, pins et users de Pinterest directement dans R, tel est l'object de rpinterest, un package destiné à faciliter le dialogue entre l'API du réseau social et votre logiciel favori. <!--more-->

### Installer rpinterest
_Update [17/08/16]_

Le package est désormais disponible sur le <a href="https://cran.r-project.org/web/packages/rpinterest/index.html">CRAN</a> !
```r
install.packages("rpinterest")
```
_[/update]_

Pour installer la version dev depuis <a href="https://github.com/ColinFay/rpinterest" target="_blank">GitHub</a>  :

```r 
devtools::install_github("ColinFay/rpinterest")
```

### Comment fonctionne rgeoapi
La version actuelle comprend 7 fonctions :
<ul>
 	<li>``BoardPinsByID` obtenir les pins d'un board à partir de l'ID d'un board</li>
 	<li>`BoardPinsByName` obtenir les pins d'un board à partir du nom d'un board</li>
 	<li>`BoardSpecByID` obtenir les informations sur un board à partir de l'ID d'un board</li>
 	<li>`BoardSpecByName` obtenir les informations sur un board à partir du nom d'un board</li>
 	<li>`PinSpecByID` obtenir les informations sur un pin à partir de son ID</li>
 	<li>`UserSpecByID` obtenir les informations sur un utilisateur à partir de son ID</li>
 	<li>` UserSpecNyName` obtenir les informations sur un utilisateur à partir de son nom</li>
</ul>
### Obtenir un acess token
Pour utiliser ces fonctions, il est indispensable d'obtenir un _access token_ disponible sur l'<a href="https://developers.pinterest.com/tools/access_token/" target="_blank">interface developpers</a> de Pinterest.

[Astuce gain de temps] Pour plus de fluidité dans votre utilisation de ce package, créez un objet R appelé _token_, et contenant la chaine de caractères de votre access token — ensuite, vous n'aurez plus qu'à insérer _token_ dans votre appel à la fonction (ce qui vous sauvera de quelques mouvements de clavier, et de quelques sueurs froides, avouons-le).
### Quelques examples
#### BoardPinsByID
Cette fonction prend l'ID d'un board et l'access token obtenu dans l'interface developpers de Pinterest, et retourne tous les pins disponibles sur ce board.

```r 
BoardPinsByID(boardID = "42080646457333782", token = token)
```
#### BoardSpecByName
Cette fonction vous permet d'obtenir les informations sur un board, à partir de son nom et du nom de l'utilisateur qui l'a créé.
```r 
BoardSpecByName(user = "colinfay", board = "blanc-mon-amour", token = token)
```
#### UserSpecByName
Comme son nom l'indique, cette fonction obtient les informations sur l’utilisateur Pinterest spécifié.
```r 
<span class="pl-c">UserSpecByName(user = "colinfay", token = token)
```
### Contact
Vos questions et feedbacks <a href="mailto:contact@colinfay.me">sont les bienvenus</a> !


