import clsx from 'clsx';
import { FC } from 'react';

type Props = {
  children: React.ReactNode;
  width?: number;
  className?: string;
};

const Card: FC<Props> = ({ children, width, className }) => {
  return (
    <div
      className={clsx('shadow rounded bg-white px-4 pb-5 pt-4', className)}
      style={{ width: `${width}px` }}
    >
      {children}
    </div>
  );
};

export default Card;
