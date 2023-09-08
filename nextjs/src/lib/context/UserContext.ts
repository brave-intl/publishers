import React, { createContext } from 'react';

import { UserType } from '@/lib/propTypes';

type UserContextType = {
  user?: UserType;
  updateUser?: React.Dispatch<Partial<UserType>>;
};
const UserContext = createContext<UserContextType>({});

export default UserContext;
