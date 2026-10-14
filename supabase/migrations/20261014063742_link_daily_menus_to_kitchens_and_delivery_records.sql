ALTER TABLE public.master_menu_harian
  ADD COLUMN mitra_id uuid;

UPDATE public.master_menu_harian
SET mitra_id = (SELECT id FROM public.mitra_dapur ORDER BY id LIMIT 1)
WHERE mitra_id IS NULL
  AND (SELECT count(*) FROM public.mitra_dapur) = 1;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM public.master_menu_harian WHERE mitra_id IS NULL) THEN
    RAISE EXCEPTION 'Cannot assign existing master menu rows: expected exactly one kitchen partner';
  END IF;
END $$;

ALTER TABLE public.master_menu_harian
  ALTER COLUMN mitra_id SET NOT NULL;

ALTER TABLE public.master_menu_harian
  ADD CONSTRAINT master_menu_harian_mitra_id_fkey
  FOREIGN KEY (mitra_id) REFERENCES public.mitra_dapur(id) ON DELETE CASCADE;

ALTER TABLE public.master_menu_harian
  DROP CONSTRAINT unique_master_menu_harian;

ALTER TABLE public.master_menu_harian
  ADD CONSTRAINT unique_master_menu_harian
  UNIQUE (mitra_id, tanggal, target_diet, waktu_makan);

ALTER TABLE public.menu_harian
  ADD COLUMN master_menu_id bigint;

ALTER TABLE public.menu_harian
  ADD CONSTRAINT menu_harian_master_menu_id_fkey
  FOREIGN KEY (master_menu_id) REFERENCES public.master_menu_harian(id) ON DELETE SET NULL;

UPDATE public.menu_harian AS mh
SET master_menu_id = mm.id,
    nama_menu = COALESCE(mh.nama_menu, mm.nama_menu)
FROM public.users AS u, public.alamat_user AS a, public.master_menu_harian AS mm
WHERE mh.user_id = u.id
  AND mh.alamat_id = a.id
  AND a.user_id = u.id
  AND mm.mitra_id = a.mitra_id
  AND mm.tanggal = mh.tanggal
  AND mm.target_diet = u.target_diet
  AND mm.waktu_makan = mh.waktu_makan;
