import { formatFullDate } from "./dates";

test("Formats the date correctly", () => {
  const date = new Date(2018, 0, 1);
  expect(formatFullDate(date)).toBe("January 01, 2018");
});
