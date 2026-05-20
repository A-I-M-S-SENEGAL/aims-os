/* =============================================================================
 * AIMS OS — Calamares slideshow
 * =============================================================================
 * Shown during the actual installation phase (after the user has clicked
 * "Installer" on the summary page). 6 slides, ~10s each, advancing on a
 * loop until the install finishes.
 *
 * Design choices:
 *   - Pure-QML text instead of pre-rendered slide images so French and
 *     English copy can be edited without a graphics tool, and so the type
 *     scales crisply on HiDPI.
 *   - Cream background (#F5EFE7) matches the rest of AIMS OS — the user
 *     sees a consistent palette from boot splash → installer → desktop.
 *   - One product logo (aims-os-logo.png) anchors every slide. No clutter.
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
        Rectangle { anchors.fill: parent; color: "#F5EFE7" }
        Column {
            anchors.centerIn: parent
            spacing: 22
            Image {
                source: "aims-os-logo.png"
                width:  220
                height: 220
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "AIMS OS 1.0"
                color: "#803018"
                font.pixelSize: 36
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "Le système d'exploitation des sciences mathématiques."
                color: "#1A1A1A"
                font.pixelSize: 18
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "African Institute for Mathematical Sciences — Sénégal"
                color: "#A0392E"
                font.pixelSize: 14
                font.italic: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // ---- Slide 2 : Stack scientifique pré-installé ----------------------
    Slide {
        Rectangle { anchors.fill: parent; color: "#F5EFE7" }
        Column {
            anchors.centerIn: parent
            spacing: 18
            width: parent.width * 0.78
            Text {
                text: "Stack scientifique pré-installé"
                color: "#803018"
                font.pixelSize: 30
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "Python · NumPy · SciPy · pandas · scikit-learn · matplotlib · SymPy"
                color: "#1A1A1A"
                font.pixelSize: 17
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
            Text {
                text: "R · tidyverse · ggplot2 · knitr · rmarkdown"
                color: "#1A1A1A"
                font.pixelSize: 17
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
            Text {
                text: "Jupyter · SageMath · Maxima · wxMaxima · GNU Octave"
                color: "#1A1A1A"
                font.pixelSize: 17
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
            Text {
                text: "GeoGebra · gnuplot · gdb · valgrind · OpenBLAS · LAPACK · FFTW · HDF5"
                color: "#1A1A1A"
                font.pixelSize: 17
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }
    }

    // ---- Slide 3 : LaTeX & rédaction de thèse ---------------------------
    Slide {
        Rectangle { anchors.fill: parent; color: "#F5EFE7" }
        Column {
            anchors.centerIn: parent
            spacing: 18
            width: parent.width * 0.78
            Text {
                text: "Rédigez votre thèse, dès le premier boot"
                color: "#803018"
                font.pixelSize: 30
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "TeX Live complet — texlive-latex-extra, texlive-science, XeTeX, LuaTeX"
                color: "#1A1A1A"
                font.pixelSize: 17
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
            Text {
                text: "Langues : français + anglais (texlive-lang-french, texlive-lang-english)"
                color: "#1A1A1A"
                font.pixelSize: 17
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
            Text {
                text: "Outils : TeXstudio · biber · latexmk · bibtex-extra"
                color: "#1A1A1A"
                font.pixelSize: 17
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }
    }

    // ---- Slide 4 : Miniforge + Flathub ----------------------------------
    Slide {
        Rectangle { anchors.fill: parent; color: "#F5EFE7" }
        Column {
            anchors.centerIn: parent
            spacing: 18
            width: parent.width * 0.78
            Text {
                text: "Miniforge3 + Flathub — pour aller plus loin"
                color: "#803018"
                font.pixelSize: 28
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "mamba & conda déjà installés dans /opt/miniforge3"
                color: "#1A1A1A"
                font.pixelSize: 17
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "$ mamba install -c conda-forge pytorch jupyterlab"
                color: "#A0392E"
                font.pixelSize: 16
                font.family: "monospace"
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "Flathub enregistré pour les apps grand public"
                color: "#1A1A1A"
                font.pixelSize: 17
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "$ flatpak install flathub org.zoom.Zoom"
                color: "#A0392E"
                font.pixelSize: 16
                font.family: "monospace"
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // ---- Slide 5 : Sécurisé par défaut ----------------------------------
    Slide {
        Rectangle { anchors.fill: parent; color: "#F5EFE7" }
        Column {
            anchors.centerIn: parent
            spacing: 18
            width: parent.width * 0.78
            Text {
                text: "Sécurisé par défaut"
                color: "#803018"
                font.pixelSize: 30
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "Pare-feu UFW actif · AppArmor en mode enforce"
                color: "#1A1A1A"
                font.pixelSize: 17
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "Mises à jour de sécurité appliquées automatiquement"
                color: "#1A1A1A"
                font.pixelSize: 17
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "Chiffrement intégral du disque (LUKS) optionnel à l'installation"
                color: "#1A1A1A"
                font.pixelSize: 17
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "SSH désactivé · port 22 fermé — à activer manuellement si besoin"
                color: "#1A1A1A"
                font.pixelSize: 17
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // ---- Slide 6 : 100 % libre, ouvert, partagé -------------------------
    Slide {
        Rectangle { anchors.fill: parent; color: "#F5EFE7" }
        Column {
            anchors.centerIn: parent
            spacing: 18
            Image {
                source: "aims-os-logo.png"
                width:  120
                height: 120
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "100 % logiciel libre"
                color: "#803018"
                font.pixelSize: 30
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "Construit sur Debian 12 · GPL-3.0"
                color: "#1A1A1A"
                font.pixelSize: 17
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "github.com/A-I-M-S-SENEGAL/aims-os"
                color: "#A0392E"
                font.pixelSize: 16
                font.family: "monospace"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "Conçu et maintenu à AIMS Sénégal · Mbour"
                color: "#1A1A1A"
                font.pixelSize: 14
                font.italic: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
