-- | Various raw transformation matrices
module ChaosBox.Math.Matrix
  (
  -- * Affine transformations
    rotation
  , translation
  , scalar
  , shearX
  , shearY
  , shear
  , reflectOrigin
  , reflectX
  , reflectY
  -- * Vector Operations
  , applyMatrix
  -- * Combinators
  , aroundMatrix
  -- * Re-exports
  , identity
  )
where

import           ChaosBox.Geometry.P2
import           Linear.Matrix        hiding (translation)
import           Linear.V2
import           Linear.V3

-- brittany --exact-print-only

affine :: a -> a -> a
       -> a -> a -> a
       -> a -> a -> a
       -> M33 a
affine
  a b c
  d e f
  g h i
  = V3
    (V3 a b c)
    (V3 d e f)
    (V3 g h i)

-- | Rotation by @t@ radians counter-clockwise
rotation :: Double -> M33 Double
rotation t = affine
  (cos t)    (sin t) 0
  (-(sin t)) (cos t) 0
  0          0       1

-- | Translation in two dimensions
translation :: P2 -> M33 Double
translation (V2 x y) = affine
  1 0 x
  0 1 y
  0 0 1

-- | Scale in two dimensions
scalar :: P2 -> M33 Double
scalar (V2 w h) = affine
  w 0 0
  0 h 0
  0 0 1

-- | Shear along the x axis
shearX :: Double -> M33 Double
shearX t = affine
  1 t 0
  0 1 0
  0 0 1

-- | Shear along the y axis
shearY :: Double -> M33 Double
shearY t = affine
  1 0 0
  t 1 0
  0 0 1

-- | Shear along the x and y axis
shear :: P2 -> M33 Double
shear (V2 x y) = shearX x !*! shearY y

-- | Reflect about the origin
reflectOrigin :: M33 Double
reflectOrigin = affine
  (-1) 0    0
  0    (-1) 0
  0    0    1

-- | Reflect about the x axis
reflectX :: M33 Double
reflectX = affine
  1 0    0
  0 (-1) 0
  0 0    1

-- | Reflect about the y axis
reflectY :: M33 Double
reflectY = affine
  (-1) 0 0
  0    1 0
  0    0 1

-- | Apply a raw transformation matrix to a 'P2'
applyMatrix :: M33 Double -> P2 -> P2
applyMatrix m (V2 x y) = V2 x0 y0
 where
  v0 = V3 x y 0
  V3 x0 y0 _ = m !* v0

-- | Perform a linear transformation around a certain point
--
-- This is useful for rotation around the center, etc.
--
aroundMatrix :: P2 -> M33 Double -> M33 Double
aroundMatrix v m = translation (-v) !*! m !*! translation v
