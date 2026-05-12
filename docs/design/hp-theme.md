# HP Visual Theme Reference

This document captures the HP-inspired visual language the project should remember when shaping future UI, product pages, or marketing surfaces.

For Memoria's macOS app, this theme is a visual reference only. When the theme conflicts with native macOS conventions, the macOS design guidelines take priority for layout, interaction, windowing, and system behavior.

## Overview

HP reads like a long-running consumer-electronics catalog crossed with an enterprise-software product page. The whole system sits on pure white with thin gray panels for alternating section bands. There is one chromatic action color, HP Electric Blue, and one ink color; together they do most of the work. Type is a single family across every surface: Forma DJR Micro, HP's bespoke geometric grotesque, set at weight 500 for headlines and 400 for body.

The signature gesture is angular blue chevrons, sharp zero-radius slashes derived from the HP wordmark's pair of parallel slashes, that anchor hero banners. Outside those decorative slashes, every other surface is rectilinear with soft 8 to 16 pixel corners on cards and a 4 pixel corner on buttons.

The system breaks into three voice modes: a white commercial body for product browsing, a dark navy slab for testimonial bands and footer-like closures, and a light fog band for utility sections. The blue accent appears only on filled CTAs, link text, chevron decorations, and featured price stamps, never as a section background.

## Key Characteristics

- Pure white canvas with deep ink body surfaces and light fog bands for section rhythm
- HP Electric Blue as the lone CTA fill and link color
- Forma DJR Micro across every surface at weights 400, 500, 600, and 700
- Cards round at 16px for product and pricing tiles; buttons sit at 4px with capitalized labels
- Geometric blue chevrons frame hero photography and reinforce the wordmark
- Dark navy slabs close pages, especially in testimonial and footer-like sections
- Section rhythm alternates utility strip, top nav, white body, fog band, ink slab, fog band, ink footer

## Colors

### Brand & Accent

- HP Electric Blue: primary CTA fill, link color, chevron decoration fill, active sub-navigation indicator
- Bright Blue: lighter variant for dark slabs
- Deep Navy: pressed state and visited-link color
- Soft Blue: pale surface for story cards and selection chips

### Surface

- Canvas: universal white page background
- Paper: card surface
- Cloud: light gray section band
- Fog: slightly darker gray surface band
- Steel: hairline border and active focus border
- Bloom Coral / Bloom Rose: sale-tag and soft pink lifestyle accents
- Storm Mist / Sea / Deep: teal-storm tones reserved for utility illustration accents

### Text

- Ink: universal body and headline text on white surfaces
- Ink Deep: pure black for the wordmark and hairline strokes
- Ink Soft: near-black for subtle variation inside dark slabs
- On Ink: white text on dark slabs
- Charcoal: muted secondary body copy
- Graphite: smaller-print metadata and legal text

### Semantic

- Bloom Deep and Bloom Wine: error and discount emphasis colors
- Storm Deep: neutral status accent

## Typography

### Font Family

The voice is single-family: Forma DJR Micro across display, body, button, and caption. The system uses weight 400 for body, 500 for display headlines, and 600 or 700 for emphasis and button labels.

### Hierarchy

Use a consistent display ladder from large hero headlines down through body, captions, link text, and button labels. Keep line-height tight for display text and a little looser for body and fine print.

### Principles

- Prefer weight changes over italics for emphasis
- Keep the visual voice calm, neutral, and slightly mechanical
- Use a single family everywhere to keep the system coherent

## Layout

### Spacing System

- Base unit: 8px with a 4px half-step
- Most card padding lands at 16px or 24px
- Section gap lands at 80px
- Utility and comparison bands use alternating white, cloud, fog, and ink surfaces

### Grid & Container

- Desktop content max-width: 1366px
- Hero surfaces can be full width
- Product grids and pricing grids collapse cleanly across desktop, tablet, and mobile

### Whitespace Philosophy

Whitespace is commercial-clean. Product and promo cards should breathe around imagery while spec rows and fine print stay compact and dense.

## Elevation & Depth

The system is mostly flat. Depth comes from color contrast and very soft shadows on cards and pricing tiles. Heavy material shadows are discouraged.

The signature decorative depth gesture is the blue chevron pair, which should be treated as a brand artifact rather than generic decoration.

## Shapes

### Border Radius Scale

- 0px: hero chevrons and full-bleed strips
- 4px: buttons and inputs
- 8px: badges and smaller cards
- 16px: product cards, pricing cards, photo frames
- pill: category tabs and filter chips

The key split is sharp interactive elements against softer container surfaces.

## Components

### Buttons

- Primary CTA: HP Electric Blue filled button with uppercase labels
- Ink CTA: black filled button for dark-photo overlays
- Outline CTA: white button with blue text and border
- Text link: inline blue link with underline

### Cards & Containers

- Product cards: white, rounded 16px, soft lift shadow
- Feature cards: cloud background, photo on one side, copy on the other
- Pricing tiers: white, rounded 16px, soft lift shadow
- Story cards: white, rounded 16px, with photo and quote
- Category icon cards: smaller rounded cards for navigation
- Hero promo card: framed hero with chevron decorations
- Dark promo strip: dark navy banner for emphasis

### Inputs & Forms

- Search input: pill or rounded search field with hairline border
- Text input: white field with subtle border and darker focus state
- Badge pills: ink-filled or outline pills for tags and labels

### Navigation

- Utility strip: dark top utility row
- Top nav: white desktop navigation with logo, links, search, and account items
- Category tabs: pill sub-navigation with active state inversion

### Signature Components

- Chevron decoration: sharp blue slash motif used only in hero or banner contexts
- FAQ row: accordion-like utility row with hairline dividers
- Help band dark: dark closure section for help and support prompts
- Footer dark: ink footer with link grid and legal lines

## Do's And Don'ts

### Do

- Reserve the blue accent for the primary CTA, link color, and chevron motif
- Use the single font family consistently
- Keep cards rounded and buttons sharper
- Alternate white, cloud, fog, and ink bands to create rhythm
- Close pages with a dark slab and footer rhythm

### Don't

- Don't introduce extra saturated colors outside the established accent families
- Don't apply heavy shadows
- Don't make buttons overly rounded
- Don't let decorative chevrons become generic inline decoration
- Don't lose the wordmark's visual specificity

## Responsive Behavior

- Preserve the surface rhythm across breakpoints
- Collapse navigation cleanly on small screens
- Keep touch targets generous
- Let hero decorations disappear or simplify on mobile rather than crowd the layout

## Usage Reminder

When working on future designs in this repository, treat this theme as a standing visual reference. For Memoria's app UI, adapt it to macOS conventions rather than copying a web page literally.
