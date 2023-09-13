'use client';

import { useEffect, useReducer } from 'react';

import { apiRequest } from '@/lib/api';
import UserContext from '@/lib/context/UserContext';
import { UserType } from '@/lib/propTypes';

function reducer(state, action) {
  switch (action.type) {
    case 'update':
      return { user: action.payload };
    default:
      throw new Error();
  }
}

export default function UserProvider({
  children,
}: {
  children: React.ReactNode;
}) {
  const [state, dispatch] = useReducer(reducer, { user: {} });

  function updateUser(payload: UserType) {
    dispatch({ type: 'update', payload });
  }

  useEffect(() => {
    async function getUser() {
      try {
        const data = await apiRequest('publishers/me');
        updateUser(data);
      } catch (err) {
        return err;
      }
    }

    getUser();
  }, []);

  return state.user.id ? (
    <UserContext.Provider value={{ user: state.user, updateUser }}>
      {children}
    </UserContext.Provider>
  ) : null;
}
