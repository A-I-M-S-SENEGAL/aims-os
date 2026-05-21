/* =============================================================================
 * AIMS OS — Calamares slideshow (Style C: photo left, text right)
 * =============================================================================
 * Shown during the actual installation phase (after the user has clicked
 * "Installer" on the summary page). 6 slides, ~10 s each, advancing on a
 * loop until the install finishes.
 *
 * Style C layout, applied uniformly to every slide:
 *
 *   ┌──────────────────────────┬────────────────────────────┐
 *   │                          │                            │
 *   │                          │   Title (terracotta bold)  │
 *   │   slide-N-*.jpg          │                            │
 *   │   (PreserveAspectCrop)   │   Body text (dark)         │
 *   │   55 % of slide width    │                            │
 *   │                          │   Tagline (italic)         │
 *   │                          │                            │
 *   └──────────────────────────┴────────────────────────────┘
 *      45 % left for photo bleed,  45 % right for text with 40 px margins.
 *
 * Photos are real AIMS Sénégal shots scraped from aims-senegal.org and the
 * recent Jëmmal Incubator material (May 2026). Zero AIMS-Rwanda imagery —
 * we explicitly avoided photos with other-centre branding visible.
 *
 * API v2: the root object exposes onActivate() / onLeave() so Calamares
 * can start/stop the advance timer without the QML having to detect it.
 *
 * Spec: https://github.com/calamares/calamares/blob/calamares/src/branding/default/show.qml
 * License: GPL-3.0-or-later (matches the rest of AIMS OS).
 * =========================================================================== */

import QtQuick 2.5
import calamares.slideshow 1.0

Presentation {
    id: presentation

    // Slideshow API v2 — Calamares calls these as it enters and leaves
    // the slideshow phase. We use them to start/stop the advance timer so
    // the slideshow is paused while Calamares is on other pages.
    function onActivate() { advanceTimer.running = true; }
    function onLeave()    { advanceTimer.running = false; }

    Timer {
        id: advanceTimer
        interval: 10000
        repeat: true
        running: false
        onTriggered: presentation.goToNextSlide()
    }

    // ---- Slide 1 : Bienvenue -------------------------------------------
    Slide {
        width:  presentation.width
        height: presentation.height

        Rectangle { anchors.fill: parent; color: "#F5EFE7" }
        Row {
            anchors.fill: parent
            Image {
                width:  parent.width * 0.55
                height: parent.height
                source: "slides/slide-1-bienvenue.jpg"
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                clip: true
            }
            Item {
                width:  parent.width * 0.45
                height: parent.height
                Column {
                    anchors.centerIn: parent
                    width:   parent.width - 80
                    spacing: 18
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "AIMS OS"
                        color: "#803018"
                        font.pixelSize: 34
                        font.bold: true
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "Le système d'exploitation des sciences mathématiques."
                        color: "#1A1A1A"
                        font.pixelSize: 17
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "African Institute for Mathematical Sciences — Sénégal"
                        color: "#A0392E"
                        font.pixelSize: 14
                        font.italic: true
                    }
                }
            }
        }
    }

    // ---- Slide 2 : Stack scientifique pré-installé ----------------------
    Slide {
        width:  presentation.width
        height: presentation.height

        Rectangle { anchors.fill: parent; color: "#F5EFE7" }
        Row {
            anchors.fill: parent
            Image {
                width:  parent.width * 0.55
                height: parent.height
                source: "slides/slide-2-stack.jpg"
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                clip: true
            }
            Item {
                width:  parent.width * 0.45
                height: parent.height
                Column {
                    anchors.centerIn: parent
                    width:   parent.width - 80
                    spacing: 14
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "Stack scientifique pré-installé"
                        color: "#803018"
                        font.pixelSize: 26
                        font.bold: true
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "Python · NumPy · SciPy · pandas · scikit-learn · matplotlib · SymPy"
                        color: "#1A1A1A"
                        font.pixelSize: 15
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "R · tidyverse · ggplot2 · knitr · rmarkdown"
                        color: "#1A1A1A"
                        font.pixelSize: 15
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "Jupyter · Maxima · wxMaxima · GNU Octave · SageMath via mamba"
                        color: "#1A1A1A"
                        font.pixelSize: 15
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "GeoGebra · gnuplot · gdb · valgrind · OpenBLAS · LAPACK · FFTW · HDF5"
                        color: "#1A1A1A"
                        font.pixelSize: 15
                    }
                }
            }
        }
    }

    // ---- Slide 3 : LaTeX & rédaction de thèse ---------------------------
    Slide {
        width:  presentation.width
        height: presentation.height

        Rectangle { anchors.fill: parent; color: "#F5EFE7" }
        Row {
            anchors.fill: parent
            Image {
                width:  parent.width * 0.55
                height: parent.height
                source: "slides/slide-3-thesis.jpg"
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                clip: true
            }
            Item {
                width:  parent.width * 0.45
                height: parent.height
                Column {
                    anchors.centerIn: parent
                    width:   parent.width - 80
                    spacing: 18
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "Rédigez votre thèse, dès le premier boot"
                        color: "#803018"
                        font.pixelSize: 26
                        font.bold: true
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "TeX Live complet — texlive-latex-extra, texlive-science, XeTeX, LuaTeX"
                        color: "#1A1A1A"
                        font.pixelSize: 16
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "Langues : français + anglais (texlive-lang-french, texlive-lang-english)"
                        color: "#1A1A1A"
                        font.pixelSize: 16
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "Outils : TeXstudio · biber · latexmk · bibtex-extra"
                        color: "#1A1A1A"
                        font.pixelSize: 16
                    }
                }
            }
        }
    }

    // ---- Slide 4 : Miniforge + Flathub ----------------------------------
    Slide {
        width:  presentation.width
        height: presentation.height

        Rectangle { anchors.fill: parent; color: "#F5EFE7" }
        Row {
            anchors.fill: parent
            Image {
                width:  parent.width * 0.55
                height: parent.height
                source: "slides/slide-4-tools.jpg"
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                clip: true
            }
            Item {
                width:  parent.width * 0.45
                height: parent.height
                Column {
                    anchors.centerIn: parent
                    width:   parent.width - 80
                    spacing: 14
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "Miniforge3 + Flathub"
                        color: "#803018"
                        font.pixelSize: 26
                        font.bold: true
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "mamba & conda déjà installés dans /opt/miniforge3"
                        color: "#1A1A1A"
                        font.pixelSize: 16
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "$ mamba install -c conda-forge pytorch jupyterlab"
                        color: "#A0392E"
                        font.pixelSize: 14
                        font.family: "monospace"
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "Flathub enregistré pour les apps grand public"
                        color: "#1A1A1A"
                        font.pixelSize: 16
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "$ flatpak install flathub org.zoom.Zoom"
                        color: "#A0392E"
                        font.pixelSize: 14
                        font.family: "monospace"
                    }
                }
            }
        }
    }

    // ---- Slide 5 : Sécurisé par défaut ----------------------------------
    Slide {
        width:  presentation.width
        height: presentation.height

        Rectangle { anchors.fill: parent; color: "#F5EFE7" }
        Row {
            anchors.fill: parent
            Image {
                width:  parent.width * 0.55
                height: parent.height
                source: "slides/slide-5-security.jpg"
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                clip: true
            }
            Item {
                width:  parent.width * 0.45
                height: parent.height
                Column {
                    anchors.centerIn: parent
                    width:   parent.width - 80
                    spacing: 16
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "Sécurisé par défaut"
                        color: "#803018"
                        font.pixelSize: 26
                        font.bold: true
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "Pare-feu UFW actif · AppArmor en mode enforce"
                        color: "#1A1A1A"
                        font.pixelSize: 16
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "Mises à jour de sécurité appliquées automatiquement"
                        color: "#1A1A1A"
                        font.pixelSize: 16
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "Chiffrement intégral du disque (LUKS) optionnel à l'installation"
                        color: "#1A1A1A"
                        font.pixelSize: 16
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "SSH désactivé · port 22 fermé — à activer manuellement si besoin"
                        color: "#1A1A1A"
                        font.pixelSize: 16
                    }
                }
            }
        }
    }

    // ---- Slide 6 : 100 % libre, ouvert, partagé -------------------------
    Slide {
        width:  presentation.width
        height: presentation.height

        Rectangle { anchors.fill: parent; color: "#F5EFE7" }
        Row {
            anchors.fill: parent
            Image {
                width:  parent.width * 0.55
                height: parent.height
                source: "slides/slide-6-libre.jpg"
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                clip: true
            }
            Item {
                width:  parent.width * 0.45
                height: parent.height
                Column {
                    anchors.centerIn: parent
                    width:   parent.width - 80
                    spacing: 18
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "100 % logiciel libre"
                        color: "#803018"
                        font.pixelSize: 28
                        font.bold: true
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "Construit sur Debian 13 · GPL-3.0"
                        color: "#1A1A1A"
                        font.pixelSize: 16
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "github.com/A-I-M-S-SENEGAL/aims-os"
                        color: "#A0392E"
                        font.pixelSize: 15
                        font.family: "monospace"
                    }
                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: "Conçu et maintenu à AIMS Sénégal · Mbour"
                        color: "#1A1A1A"
                        font.pixelSize: 13
                        font.italic: true
                    }
                }
            }
        }
    }
}
