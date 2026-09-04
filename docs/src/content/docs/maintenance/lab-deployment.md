---
title: Déploiement labo
description: Comment les postes fixes d'un labo AIMS démarrent par le réseau, s'installent sans clé USB, se clonent et s'authentifient sur un annuaire.
---

Cette page présente, dans les grandes lignes, la façon dont un labo
AIMS déploie et administre ses postes fixes avec AIMS OS. Les adresses,
noms de serveurs, procédures détaillées et accès sont dans le mode
d'emploi interne de l'équipe IT (dépôt privé), pas ici.

## Vue d'ensemble

Un serveur du campus héberge quatre services, chacun dans son conteneur :

- **FOG** : démarrage des postes par le réseau (PXE), installation
  d'AIMS OS sans clé USB, capture d'un poste modèle et clonage d'une
  salle entière (multicast). FOG ne fait jamais DHCP : le pare-feu du
  campus reste le seul serveur DHCP.
- **Cache APT** : un poste télécharge un paquet Debian une fois, les
  suivants le prennent sur le réseau local. Les postes le détectent
  automatiquement et fonctionnent sans lui hors campus.
- **Annuaire FreeIPA** : comptes des étudiants et des enseignants,
  mots de passe, groupes, et règles d'accès aux postes.
- **Accès distant** de l'équipe IT, protégé par une authentification
  en amont ; rien n'est exposé directement sur Internet.

## Préparer un poste

Les postes doivent démarrer en **UEFI seul** (démarrage legacy
désactivé, Secure Boot désactivé, carte réseau en premier dans l'ordre
de démarrage). Le détail par modèle est dans le mode d'emploi interne.

## Installer et cloner

1. Le poste démarre sur le réseau et affiche le menu FOG ; une entrée
   lance l'installateur AIMS OS (ISO courante servie par le serveur).
2. Le poste modèle reçoit ensuite le paquet `aims-os-centre-senegal-labo`
   (accès SSH par clé pour l'équipe IT, jamais de veille, horloge
   synchronisée), puis est capturé dans FOG.
3. Chaque clone est ensuite **enrôlé** dans l'annuaire, avec sa propre
   identité. On n'enrôle jamais le poste modèle avant capture.

## Comptes et postes

Chaque étudiant a un identifiant unique, valable sur le poste qui lui
est **attribué** et uniquement celui-là ; les enseignants entrent
partout. Le dossier personnel est créé à la première connexion et un
mot de passe oublié se réinitialise depuis l'interface de l'annuaire.
Chaque ouverture de session est journalisée (qui, quel poste, quand),
ce qui rend le suivi du matériel fiable. L'attribution, la libération
et le rapport de connexions se font avec l'outil `aims-labo` sur le
serveur.

## Pièges connus

- **Menu FOG puis « Boot from SAN device failed » ou GRUB4DOS** : le
  poste est en legacy. Repasser le BIOS en UEFI seul.
- **Noyau qui panique avec « Initramfs unpacking failed »** juste après
  le menu FOG : le type de sortie FOG doit être `exit`, pas rEFInd.
- **Poste qui ne s'éteint pas** à la fin d'une installation lancée par
  le réseau : corrigé dans AIMS OS 2.1.2 (redémarrage immédiat).
- **Dates en wolof** après installation : corrigé dans AIMS OS 2.1.3
  (locale fr_FR forcée au premier démarrage).
- **Poste installé avant AIMS OS 2.1.3 sans `aims-os-desktop`** :
  `sudo apt install aims-os-desktop` une fois.
