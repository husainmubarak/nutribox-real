-- Allow kitchen partners to access only delivery data assigned to their kitchen.

DROP POLICY IF EXISTS alamat_select_assigned_kitchen ON public.alamat_user;
CREATE POLICY alamat_select_assigned_kitchen
  ON public.alamat_user
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR mitra_id = auth.uid());

DROP POLICY IF EXISTS users_select_assigned_kitchen ON public.users;
CREATE POLICY users_select_assigned_kitchen
  ON public.users
  FOR SELECT
  TO authenticated
  USING (
    id = auth.uid()
    OR EXISTS (
      SELECT 1
      FROM public.alamat_user AS address
      WHERE address.user_id = users.id
        AND address.mitra_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS transaksi_select_assigned_kitchen ON public.transaksi_langganan;
CREATE POLICY transaksi_select_assigned_kitchen
  ON public.transaksi_langganan
  FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1
      FROM public.alamat_user AS address
      WHERE address.user_id = transaksi_langganan.user_id
        AND address.mitra_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS jadwal_select_assigned_kitchen ON public.jadwal_pengiriman;
CREATE POLICY jadwal_select_assigned_kitchen
  ON public.jadwal_pengiriman
  FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1
      FROM public.alamat_user AS address
      WHERE address.id = jadwal_pengiriman.alamat_id
        AND address.user_id = jadwal_pengiriman.user_id
        AND address.mitra_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS menu_harian_select_assigned_kitchen ON public.menu_harian;
CREATE POLICY menu_harian_select_assigned_kitchen
  ON public.menu_harian
  FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1
      FROM public.alamat_user AS address
      WHERE address.id = menu_harian.alamat_id
        AND address.user_id = menu_harian.user_id
        AND address.mitra_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS menu_harian_insert_authenticated ON public.menu_harian;
CREATE POLICY menu_harian_insert_own_or_assigned
  ON public.menu_harian
  FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1
      FROM public.alamat_user AS address
      WHERE address.id = menu_harian.alamat_id
        AND address.user_id = menu_harian.user_id
        AND address.mitra_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS menu_harian_update_assigned_kitchen ON public.menu_harian;
CREATE POLICY menu_harian_update_assigned_kitchen
  ON public.menu_harian
  FOR UPDATE
  TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1
      FROM public.alamat_user AS address
      WHERE address.id = menu_harian.alamat_id
        AND address.user_id = menu_harian.user_id
        AND address.mitra_id = auth.uid()
    )
  )
  WITH CHECK (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1
      FROM public.alamat_user AS address
      WHERE address.id = menu_harian.alamat_id
        AND address.user_id = menu_harian.user_id
        AND address.mitra_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS master_menu_write_authenticated ON public.master_menu_harian;
CREATE POLICY master_menu_write_own_kitchen
  ON public.master_menu_harian
  FOR ALL
  TO authenticated
  USING (mitra_id = auth.uid())
  WITH CHECK (mitra_id = auth.uid());
