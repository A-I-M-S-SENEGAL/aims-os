// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import { starlightBasePath } from 'starlight-base-path';

// AIMS OS docs site.
//
// Hosted under the existing GitHub Pages site at
// https://a-i-m-s-senegal.github.io/aims-os/docs/. The apt repo lives at the
// root of the same Pages site; the publish workflow merges Starlight's `dist`
// into `apt-repo/site/docs/` before uploading the unified tree.
export default defineConfig({
  site: 'https://a-i-m-s-senegal.github.io',
  base: '/aims-os/docs',
  // Trailing slashes match the deployed URL shape (GH Pages serves
  // `/foo/` with the index.html inside).
  trailingSlash: 'always',
  integrations: [
    starlight({
      title: 'AIMS OS',
      logo: {
        src: './src/assets/aims-logo.png',
        replacesTitle: false,
      },
      favicon: '/favicon.png',
      // Bilingual setup. French is the root locale (no URL prefix —
      // pages live at /docs/install/iso/ etc.), English is under /en/
      // (so /docs/en/install/iso/). Starlight shows a language picker
      // in the top bar automatically. Per-page translation lives at
      // src/content/docs/en/<same-path-as-fr>.md.
      defaultLocale: 'root',
      locales: {
        root: { label: 'Français', lang: 'fr' },
        en:   { label: 'English',  lang: 'en' },
      },
      social: [
        {
          icon: 'github',
          label: 'GitHub',
          href: 'https://github.com/A-I-M-S-SENEGAL/aims-os',
        },
      ],
      editLink: {
        baseUrl: 'https://github.com/A-I-M-S-SENEGAL/aims-os/edit/main/docs/',
      },
      customCss: ['./src/styles/custom.css'],
      // Auto-prepend the configured `base` (/aims-os/docs) to absolute
      // root-anchored links inside Markdown content. Starlight handles
      // the base for its own sidebar / nav links but NOT for arbitrary
      // `[text](/install/iso/)` constructions in MDX. The plugin runs as
      // a remark transformer so we keep human-friendly paths in source
      // and the deployed HTML resolves to the right URL.
      plugins: [starlightBasePath()],
      sidebar: [
        // Site root (index.mdx) is reachable via the title / logo, not
        // via the sidebar — Starlight rejects `slug: "index"`.
        // Labels default to French (root locale); `translations.en` gives
        // the English version of each label on /en/ pages.
        {
          label: 'Démarrer',
          translations: { en: 'Get started' },
          items: [
            {
              label: 'Installer depuis l\'ISO',
              translations: { en: 'Install from the ISO' },
              slug: 'install/iso',
            },
            {
              label: 'Sur Debian existant (apt)',
              translations: { en: 'On existing Debian (apt)' },
              slug: 'install/apt',
            },
            {
              label: 'Premier démarrage',
              translations: { en: 'First boot' },
              slug: 'install/first-boot',
            },
          ],
        },
        {
          label: 'Filières',
          translations: { en: 'Tracks' },
          items: [
            {
              label: 'Regular — Sciences Math',
              translations: { en: 'Regular — Mathematical Sciences' },
              slug: 'filieres/regular',
            },
            {
              label: 'Coop — Big Data',
              translations: { en: 'Coop — Big Data' },
              slug: 'filieres/bigdata',
            },
            {
              label: 'Coop — Security',
              translations: { en: 'Coop — Computer Security' },
              slug: 'filieres/security',
            },
          ],
        },
        {
          label: 'Cours 2025-2026',
          translations: { en: '2025-2026 Courses' },
          items: [
            {
              label: 'Cartographie cours → outils',
              translations: { en: 'Course → tool mapping' },
              slug: 'courses/mapping',
            },
          ],
        },
        {
          label: 'Maintenance',
          translations: { en: 'Maintenance' },
          items: [
            {
              label: 'Politique de maintenance',
              translations: { en: 'Maintenance policy' },
              slug: 'maintenance/policy',
            },
          ],
        },
        // Dépannage and Contribuer groups are deliberately omitted for v1.
        // Starlight 0.39 renders empty autogenerate groups as empty
        // expandable items in the sidebar (intentional transparency,
        // see withastro/starlight#1409). Re-add them with real content,
        // not as placeholders, when troubleshooting/ and contributing/
        // grow real pages.
      ],
    }),
  ],
});
