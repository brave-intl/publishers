export function formatFullDate(date) {
  return date.toLocaleDateString("en-US", { month: 'long', day: '2-digit', year: 'numeric' });
}
