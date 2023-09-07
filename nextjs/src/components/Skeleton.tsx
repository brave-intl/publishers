import clsx from 'clsx';
import * as React from 'react';

type SkeletonProps = React.ComponentPropsWithoutRef<'div'>;

// Ripped from tailwind, need to duplicate animate-shimmer animation
export default function Skeleton({ className, ...rest }: SkeletonProps) {
  return (
    <div
      className={clsx('animate-shimmer bg-[#f6f7f8]', className)}
      style={{
        backgroundImage:
          'linear-gradient(to right, #f6f7f8 0%, #edeef1 20%, #f6f7f8 40%, #f6f7f8 100%)',
        backgroundSize: '700px 100%',
        backgroundRepeat: 'no-repeat',
      }}
      {...rest}
    />
  );
}
