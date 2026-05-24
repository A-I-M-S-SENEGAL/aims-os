// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

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
      defaultLocale: 'fr',
      locales: {
        fr: { label: 'Français', lang: 'fr' },
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
      components: {
        // Replace Starlight's default Hero with our editorial layout
        // (matches the apt-repo landing visual identity).
        Hero: './src/components/Hero.astro',
      },
      sidebar: [
        {
          // Site root (index.mdx) is reachable via the title / logo, not
          // via the sidebar — Starlight rejects `slug: "index"`.
          label: 'Démarrer',
          items: [
            { label: 'Installer depuis l\'ISO', slug: 'install/iso' },
            { label: 'Sur Debian existant (apt)', slug: 'install/apt' },
            { label: 'Premier démarrage', slug: 'install/first-boot' },
          ],
        },
        {
          label: 'Filières',
          items: [
            { label: 'Regular — Sciences Math', slug: 'filieres/regular' },
            { label: 'Coop — Big Data', slug: 'filieres/bigdata' },
            { label: 'Coop — Security', slug: 'filieres/security' },
          ],
        },
        {
          label: 'Cours 2025-2026',
          items: [
            { label: 'Cartographie cours → outils', slug: 'courses/mapping' },
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
