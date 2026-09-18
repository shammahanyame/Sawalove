-- Optional starter data for a new Supabase project.
-- Run this after supabase/migrations/20260602000000_initial_schema.sql if
-- the discovery screen is empty and you want demo profiles while testing.

insert into public.users (
  id,
  name,
  age,
  city,
  location,
  village,
  goal,
  intent,
  bio,
  photo,
  visible,
  "isPremium",
  lat,
  lng,
  distance
)
values
  (
    '10000000-0000-4000-8000-000000000001',
    'Amaka',
    28,
    'Douala',
    'Douala, Littoral',
    'Batoufam',
    'Serious relationship',
    'serious',
    'Loves art, music, family gatherings, and weekend trips around Cameroon.',
    'https://picsum.photos/800/1200?random=201',
    true,
    false,
    0.01,
    0.02,
    2.5
  ),
  (
    '10000000-0000-4000-8000-000000000002',
    'Mireille',
    26,
    'Yaounde',
    'Yaounde, Centre',
    'Bafoussam',
    'Marriage minded',
    'marriage',
    'Faith, career, good food, and honest conversation matter most to me.',
    'https://picsum.photos/800/1200?random=202',
    true,
    true,
    0.03,
    -0.01,
    5.1
  ),
  (
    '10000000-0000-4000-8000-000000000003',
    'Aicha',
    29,
    'Buea',
    'Buea, Southwest',
    'Garoua',
    'Friendship first',
    'friendship',
    'Entrepreneur, coffee person, and always ready for a thoughtful walk.',
    'https://picsum.photos/800/1200?random=203',
    true,
    false,
    -0.02,
    0.04,
    8.4
  )
on conflict (id) do update set
  name = excluded.name,
  age = excluded.age,
  city = excluded.city,
  location = excluded.location,
  village = excluded.village,
  goal = excluded.goal,
  intent = excluded.intent,
  bio = excluded.bio,
  photo = excluded.photo,
  visible = excluded.visible,
  "isPremium" = excluded."isPremium",
  lat = excluded.lat,
  lng = excluded.lng,
  distance = excluded.distance,
  updated_at = now();
