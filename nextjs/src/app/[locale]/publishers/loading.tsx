export default function Loading() {
  // You can add any UI inside Loading, including a Skeleton.
  return (
    <div className='bg-main absolute flex h-full w-full justify-center'>
      <div className='mt-[200px] h-[100px] w-[100px]'>
        <svg className='animate-spin' viewBox='0 0 50 50'>
          <circle
            cx='25'
            cy='25'
            r='20'
            fill='none'
            stroke='var(--leo-color-container-background)'
            stroke-width='5'
          />
          <circle
            strokeLinecap='round'
            className='animate-dash'
            cx='25'
            cy='25'
            r='20'
            fill='none'
            stroke='#fd2f00'
            stroke-width='5'
          />
        </svg>
      </div>
    </div>
  );
}
