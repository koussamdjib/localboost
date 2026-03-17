from django.core.management.base import BaseCommand
from django.utils import timezone

from apps.deals.models import Deal, DealStatus


class Command(BaseCommand):
	help = "Archive deals whose end date has passed."

	def add_arguments(self, parser):
		parser.add_argument(
			"--dry-run",
			action="store_true",
			help="Print which deals would be archived without making changes.",
		)

	def handle(self, *args, **options):
		dry_run = options["dry_run"]
		now = timezone.now()

		expired = Deal.objects.filter(
			status=DealStatus.PUBLISHED,
			ends_at__lt=now,
		)

		count = expired.count()
		if count == 0:
			self.stdout.write(self.style.SUCCESS("No expired deals found."))
			return

		for deal in expired:
			self.stdout.write(
				f"  {'[DRY RUN] ' if dry_run else ''}Archiving: {deal.title} "
				f"(shop={deal.shop_id}, ended={deal.ends_at})"
			)

		if not dry_run:
			updated = expired.update(status=DealStatus.ARCHIVED)
			self.stdout.write(
				self.style.SUCCESS(f"Archived {updated} expired deal(s).")
			)
		else:
			self.stdout.write(
				self.style.WARNING(f"DRY RUN: {count} deal(s) would be archived.")
			)
