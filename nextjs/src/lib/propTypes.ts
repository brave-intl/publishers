export type UserType = {
  id: string;
  name: string;
  streetAddress: string;
  cityStateZip: string;
  phone: string;
  username: string;
  password: string;
  email: string;
  pending_email: string;
  avatar: string;
  thirty_day_login: boolean;
  subscribed_to_marketing_emails: boolean;
  two_factor_enabled: boolean;
  u2f_registrations: Array<{ name: string; created_at: string; id: string }>;
};
