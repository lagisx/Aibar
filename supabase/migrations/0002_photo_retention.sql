-- Auto-delete uploaded source photos after N days (default 7) to limit how
-- long face photos are retained. Requires the `pg_cron` extension, which is
-- enabled by default on Supabase projects.
create extension if not exists pg_cron;

create or replace function public.purge_old_source_photos()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from storage.objects
  where bucket_id = 'source-photos'
    and created_at < now() - interval '7 days';
end;
$$;

select cron.unschedule(jobid)
from cron.job
where jobname = 'purge-old-source-photos';

select cron.schedule(
  'purge-old-source-photos',
  '0 3 * * *', -- daily at 03:00 UTC
  $$select public.purge_old_source_photos();$$
);
