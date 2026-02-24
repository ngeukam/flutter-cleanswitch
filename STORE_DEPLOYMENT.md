# Guide de Déploiement - Clean Switch Staff (Application Propriétaire)

Ce document contient les informations nécessaires pour publier l'application sur le Google Play Store et l'Apple App Store en tant qu'application interne/propriétaire.

## 1. Stratégie de Distribution

### Apple App Store (iOS)
- **Unlisted App Distribution (Recommandé) :** L'application est sur le store mais invisible dans les recherches. Accessible uniquement via un lien direct envoyé à vos équipes. [Formulaire de demande Apple](https://developer.apple.com/contact/request/unlisted-app-distribution/).
- **Alternative :** Apple Business Manager (ABM) pour une gestion d'entreprise plus stricte.

### Google Play Store (Android)
- **Production fermée :** Publication restreinte à une liste d'adresses e-mail spécifique.
- **Managed Google Play :** Pour une distribution interne au sein d'une organisation.

---

## 2. Contenu des Fiches Store

**Nom :** Clean Switch Staff
**Description Courte :** Gestion interne des prestations de ménage Airbnb.

**Description Longue :**
Clean Switch Staff est l’outil de gestion interne pour les équipes de ménage partenaires. 
*Note : L'accès à cette application est restreint. Un compte pré-approuvé fourni par l'administrateur est requis pour l'utilisation.*

**Note pour les examinateurs (App Review) :**
> "Cette application est un outil interne propriétaire destiné exclusivement au personnel de ménage de notre service de conciergerie. Elle n'est pas destinée au grand public. Les utilisateurs reçoivent leurs identifiants directement de notre administration."

---

## 3. Justification de l'utilisation des données

### Géolocalisation (GPS)
- **Justification :** UTILISÉE UNIQUEMENT AU POINTAGE. "La localisation est nécessaire pour certifier la présence du prestataire sur le lieu du logement (mission) au moment du Check-in/Check-out."

### Appareil Photo / Photos
- **Justification :** "Permet l'envoi de preuves visuelles (photos avant/après) de la prestation pour validation interne."

---

## 4. Pré-requis pour le déploiement
1. **Compte Développeur :** Google Play Console (~25$ unique) et Apple Developer Program (~99$/an).
2. **Politique de Confidentialité :** Un lien URL est obligatoire. Créez une page simple précisant que les données sont utilisées à des fins internes uniquement.
3. **Compte de Test :** Fournir un identifiant et mot de passe de test aux examinateurs de Apple/Google.
