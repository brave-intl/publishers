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
      className={clsx(
        'shadow bg-container rounded px-2 md:px-4 pb-5 pt-4 transition-colors',
        className,
      )}
      style={{ width: `${width}px` }}
    >
      {children}
    </div>
  );
};

export default Card;
