'use client';

import { createContext, useReducer } from 'react';

function reducer(state, action) {
  switch (action.type) {
    case 'ADD_ADDRESS':
      state.addressesInUse.push(action.payload.newAddress);
      return state;
    case 'REMOVE_ADDRESS': {
      const idx = state.addressesInUse.findIndex(
        (address) => address.id === action.payload.removedAddress,
      );
      const newState = { ...state };

      if (idx > -1) {
        newState.addressesInUse.splice(idx, 1);
      }
      return newState;
    }
    case 'UPDATE_RESPONSE_DATA':
      return { ...state, currentResponseData: action.payload };
    default:
      return state;
  }
}

export const CryptoAddressContext = createContext({
  addressesInUse: [],
  currentResponseData: [],
  addAddressInUse: ({}) => {},
  removeAddressInUse: ({}) => {},
  updateResponseData: ({}) => {},
});

export default function CryptoAddressProvider({
  children,
}: {
  children: React.ReactNode;
}) {
  const [state, dispatch] = useReducer(reducer, {
    addressesInUse: [],
    currentResponseData: [],
  });

  function addAddressInUse(payload) {
    dispatch({ type: 'ADD_ADDRESS', payload });
  }

  function removeAddressInUse(payload) {
    dispatch({ type: 'REMOVE_ADDRESS', payload });
  }

  function updateResponseData(payload) {
    dispatch({ type: 'UPDATE_RESPONSE_DATA', payload });
  }

  return (
    <CryptoAddressContext.Provider
      value={{
        ...state,
        addAddressInUse,
        removeAddressInUse,
        updateResponseData,
      }}
    >
      {children}
    </CryptoAddressContext.Provider>
  );
}