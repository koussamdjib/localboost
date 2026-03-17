from django.urls import path

from apps.transactions.views import TransactionHistoryListView

urlpatterns = [
    path("", TransactionHistoryListView.as_view(), name="transaction-list"),
]
