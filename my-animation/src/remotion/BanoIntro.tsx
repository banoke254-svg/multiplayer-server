/** @jsxImportSource react */
import React, {useMemo} from 'react';
import {ThreeCanvas} from '@remotion/three';
import {PerspectiveCamera, Sparkles} from '@react-three/drei';
import {Bloom, EffectComposer, Vignette} from '@react-three/postprocessing';
import {
  AbsoluteFill,
  Img,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';
import * as THREE from 'three';
import './BanoIntro.css';

const clamp = {
  extrapolateLeft: 'clamp' as const,
  extrapolateRight: 'clamp' as const,
};

const ease = (value: number) => value * value * (3 - 2 * value);

const randomRange = (seed: number, min: number, max: number) => {
  const x = Math.sin(seed * 12.9898) * 43758.5453;
  return min + (x - Math.floor(x)) * (max - min);
};

const NeonParticles = ({frame}: {frame: number}) => {
  const particles = useMemo(
    () =>
      Array.from({length: 86}, (_, index) => ({
        x: randomRange(index + 4, -8, 8),
        y: randomRange(index + 22, -1.5, 6),
        z: randomRange(index + 40, -18, 8),
        size: randomRange(index + 60, 0.025, 0.08),
        speed: randomRange(index + 80, 0.004, 0.018),
        hue: index % 3,
      })),
    [],
  );

  return (
    <group>
      {particles.map((particle, index) => {
        const y = particle.y + Math.sin(frame * particle.speed + index) * 0.45;
        const x = particle.x + Math.cos(frame * particle.speed * 0.7 + index) * 0.25;
        const color = particle.hue === 0 ? '#b55cff' : particle.hue === 1 ? '#36d8ff' : '#f4d6ff';

        return (
          <mesh key={index} position={[x, y, particle.z]}>
            <sphereGeometry args={[particle.size, 12, 12]} />
            <meshBasicMaterial color={color} transparent opacity={0.78} />
          </mesh>
        );
      })}
    </group>
  );
};

const ArenaFloor = ({frame}: {frame: number}) => {
  const lightUp = interpolate(frame, [75, 145], [0, 1], clamp);
  const strips = useMemo(() => Array.from({length: 9}, (_, index) => index - 4), []);
  const hexes = useMemo(
    () =>
      Array.from({length: 28}, (_, index) => ({
        x: (index % 5 - 2) * 1.72 + (Math.floor(index / 5) % 2) * 0.86,
        z: -13 + Math.floor(index / 7) * 1.42,
      })),
    [],
  );

  return (
    <group>
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, -1.42, -7]}>
        <planeGeometry args={[34, 34]} />
        <meshStandardMaterial
          color="#05040b"
          emissive="#10001e"
          emissiveIntensity={0.25}
          metalness={0.85}
          roughness={0.18}
        />
      </mesh>

      {strips.map((strip) => {
        const delay = Math.abs(strip) * 5;
        const opacity = interpolate(frame, [86 + delay, 130 + delay], [0, 0.95], clamp);

        return (
          <mesh key={`z-${strip}`} rotation={[-Math.PI / 2, 0, 0]} position={[strip * 1.55, -1.37, -7]}>
            <planeGeometry args={[0.035, 30]} />
            <meshBasicMaterial
              color={strip % 2 === 0 ? '#8f37ff' : '#22d7ff'}
              transparent
              opacity={opacity * lightUp}
            />
          </mesh>
        );
      })}

      {strips.map((strip) => {
        const opacity = interpolate(frame, [98 + Math.abs(strip) * 4, 156], [0, 0.58], clamp);

        return (
          <mesh key={`x-${strip}`} rotation={[-Math.PI / 2, 0, Math.PI / 2]} position={[0, -1.365, -7 + strip * 1.5]}>
            <planeGeometry args={[0.025, 32]} />
            <meshBasicMaterial color="#6940ff" transparent opacity={opacity} />
          </mesh>
        );
      })}

      {hexes.map((hex, index) => {
        const opacity = interpolate(frame, [62 + index * 1.2, 146], [0, 0.42], clamp);

        return (
          <mesh key={`hex-${index}`} rotation={[-Math.PI / 2, 0, Math.PI / 6]} position={[hex.x, -1.353, hex.z]}>
            <ringGeometry args={[0.58, 0.6, 6]} />
            <meshBasicMaterial color={index % 3 === 0 ? '#ffb12a' : '#a83fff'} transparent opacity={opacity * lightUp} side={THREE.DoubleSide} />
          </mesh>
        );
      })}
    </group>
  );
};

const EnergyCracks = ({frame}: {frame: number}) => {
  const burst = interpolate(frame, [152, 205], [0, 1], clamp);
  const cracks = useMemo(
    () =>
      Array.from({length: 18}, (_, index) => ({
        angle: (index / 18) * Math.PI * 2,
        length: randomRange(index + 220, 1.2, 3.8),
        width: randomRange(index + 260, 0.016, 0.045),
      })),
    [],
  );

  return (
    <group position={[0, 0.35, -3.2]} scale={burst}>
      {cracks.map((crack, index) => (
        <mesh
          key={index}
          rotation={[0, 0, crack.angle]}
          position={[
            Math.cos(crack.angle) * crack.length * 0.35,
            Math.sin(crack.angle) * crack.length * 0.35,
            0,
          ]}
        >
          <boxGeometry args={[crack.length, crack.width, 0.03]} />
          <meshBasicMaterial color={index % 2 === 0 ? '#c27cff' : '#55e5ff'} transparent opacity={0.72 * (1 - burst * 0.35)} />
        </mesh>
      ))}
    </group>
  );
};

const GoldMaterial = ({opacity}: {opacity: number}) => (
  <meshStandardMaterial
    color="#ffb727"
    emissive="#ff7a00"
    emissiveIntensity={0.22}
    metalness={0.88}
    roughness={0.16}
    transparent
    opacity={opacity}
  />
);

const AngularGoldB = ({frame}: {frame: number}) => {
  const reveal = spring({frame: frame - 18, fps: 30, config: {damping: 180, stiffness: 90}});
  const pulse = 0.55 + Math.sin(frame * 0.11) * 0.14;
  const opacity = interpolate(frame, [18, 75], [0, 1], clamp);
  const shine = 0.2 + Math.sin(frame * 0.09) * 0.12;

  return (
    <group position={[0, 0.02, 0.68]} rotation={[0, 0, -0.16]} scale={(0.6 + reveal * 0.52) * (1 + shine * 0.025)}>
      <mesh position={[-0.22, 0, 0]} rotation={[0, 0, -0.28]}>
        <boxGeometry args={[0.18, 1.28, 0.1]} />
        <GoldMaterial opacity={opacity} />
      </mesh>
      <mesh position={[0.12, 0.42, 0]} rotation={[0, 0, 1.24]}>
        <boxGeometry args={[0.18, 0.94, 0.1]} />
        <GoldMaterial opacity={opacity} />
      </mesh>
      <mesh position={[0.24, 0.08, 0]} rotation={[0, 0, -1.02]}>
        <boxGeometry args={[0.18, 0.82, 0.1]} />
        <GoldMaterial opacity={opacity} />
      </mesh>
      <mesh position={[0.05, -0.38, 0]} rotation={[0, 0, 0.92]}>
        <boxGeometry args={[0.18, 0.98, 0.1]} />
        <GoldMaterial opacity={opacity} />
      </mesh>
      <mesh position={[-0.02, 0.02, -0.02]} rotation={[0, 0, -0.18]}>
        <ringGeometry args={[0.53, 0.57, 4]} />
        <meshBasicMaterial color="#ff9f1a" transparent opacity={0.42 * opacity} side={THREE.DoubleSide} />
      </mesh>
      <mesh position={[0, -0.06, 0.01]} rotation={[0, 0, 0.16]}>
        <torusGeometry args={[0.74, 0.026, 10, 80, Math.PI * 1.42]} />
        <meshBasicMaterial color="#ff9d1f" transparent opacity={0.82 * opacity} />
      </mesh>
      <mesh position={[0, 0.03, 0.02]} rotation={[0, 0, -0.58]}>
        <torusGeometry args={[0.88, 0.018, 10, 90, Math.PI * 1.62]} />
        <meshBasicMaterial color="#b833ff" transparent opacity={0.72 * opacity} />
      </mesh>
      <pointLight color="#ffb12a" intensity={12 * pulse * reveal} distance={4} />
    </group>
  );
};

const MarbleShellLines = ({frame}: {frame: number}) => {
  const lines = useMemo(() => Array.from({length: 10}, (_, index) => index), []);

  return (
    <group rotation={[frame * 0.006, frame * 0.012, 0]}>
      {lines.map((line) => (
        <mesh key={line} rotation={[line * 0.26, line * 0.33, line * 0.19]}>
          <torusGeometry args={[1.012, 0.006, 8, 80]} />
          <meshBasicMaterial color={line % 2 === 0 ? '#b63cff' : '#ff9f1f'} transparent opacity={0.22} />
        </mesh>
      ))}
    </group>
  );
};

const Marble = ({frame}: {frame: number}) => {
  const launch = interpolate(frame, [62, 128], [0, 1], clamp);
  const jump = interpolate(frame, [135, 190], [0, 1], clamp);
  const settle = interpolate(frame, [205, 245], [0, 1], clamp);
  const x = interpolate(ease(launch), [0, 1], [-1.35, 1.45]);
  const z = interpolate(ease(launch), [0, 1], [-5.8, -11.1]);
  const y = -0.36 + Math.sin(jump * Math.PI) * 3.2 + settle * 0.75;
  const finalX = interpolate(settle, [0, 1], [x, 0]);
  const finalZ = interpolate(settle, [0, 1], [z, -5.4]);
  const scale = interpolate(frame, [0, 40, 155, 220], [0.82, 1, 1.06, 1.12], clamp);

  return (
    <group position={[finalX, y, finalZ]} rotation={[frame * 0.035, frame * 0.052, frame * 0.019]} scale={scale}>
      <mesh>
        <sphereGeometry args={[1, 64, 64]} />
        <meshPhysicalMaterial
          color="#160328"
          emissive="#7618ff"
          emissiveIntensity={0.55 + Math.sin(frame * 0.08) * 0.14}
          metalness={0.18}
          roughness={0.08}
          transmission={0.35}
          thickness={0.85}
          clearcoat={1}
          clearcoatRoughness={0.05}
        />
      </mesh>

      <mesh scale={1.015}>
        <sphereGeometry args={[1, 42, 42]} />
        <meshBasicMaterial color="#bf38ff" wireframe transparent opacity={0.13} />
      </mesh>

      <MarbleShellLines frame={frame} />
      <AngularGoldB frame={frame} />
      <pointLight color="#ab3dff" intensity={18} distance={6} />
      <pointLight color="#ff9d1f" intensity={9} distance={8} position={[1.7, 0.4, 0.7]} />
    </group>
  );
};

const NeonTrail = ({frame}: {frame: number}) => {
  const trail = interpolate(frame, [72, 132, 175], [0, 1, 0.2], clamp);
  const length = interpolate(trail, [0, 1], [0.1, 7.5]);

  return (
    <group position={[-0.2, -0.98, -8.6]}>
      <mesh rotation={[-Math.PI / 2, 0, -0.2]} position={[-2.1, 0, 0]}>
        <planeGeometry args={[length, 0.16]} />
        <meshBasicMaterial color="#ff9d1f" transparent opacity={0.92 * trail} side={THREE.DoubleSide} />
      </mesh>
      <mesh rotation={[-Math.PI / 2, 0, -0.2]} position={[-2.1, 0.01, 0]}>
        <planeGeometry args={[length * 0.92, 0.46]} />
        <meshBasicMaterial color="#b13fff" transparent opacity={0.24 * trail} side={THREE.DoubleSide} />
      </mesh>
    </group>
  );
};

const BanoThreeScene = () => {
  const frame = useCurrentFrame();
  const {width, height} = useVideoConfig();
  const cameraZ = interpolate(frame, [0, 75, 130, 215, 280], [10.2, 7.8, 8.8, 7.35, 7.7], clamp);
  const cameraY = interpolate(frame, [0, 130, 175, 235], [1.32, 1.12, 2.7, 1.55], clamp);
  const cameraX = interpolate(frame, [80, 140, 190, 235], [0, -0.82, 0.94, 0], clamp);

  return (
    <ThreeCanvas width={width} height={height} gl={{antialias: true, alpha: false}} dpr={1}>
      <color attach="background" args={['#010106']} />
      <fog attach="fog" args={['#070016', 4, 19]} />

      <PerspectiveCamera makeDefault position={[cameraX, cameraY, cameraZ]} fov={37} near={0.1} far={80} />
      <ambientLight color="#240044" intensity={0.42} />
      <directionalLight color="#8e36ff" intensity={1.5} position={[-4, 6, 4]} />
      <pointLight color="#28cfff" intensity={15} distance={12} position={[4, 1.8, -6]} />

      <ArenaFloor frame={frame} />
      <NeonTrail frame={frame} />
      <Marble frame={frame} />
      <EnergyCracks frame={frame} />
      <NeonParticles frame={frame} />
      <Sparkles count={76} speed={0.25} opacity={0.72} scale={[9, 10, 16]} size={2.6} color="#bf66ff" position={[0, 1.2, -6]} />

      <EffectComposer>
        <Bloom luminanceThreshold={0.15} luminanceSmoothing={0.22} intensity={1.8} mipmapBlur />
        <Vignette eskil={false} offset={0.18} darkness={0.82} />
      </EffectComposer>
    </ThreeCanvas>
  );
};

const LogoOverlay = () => {
  const frame = useCurrentFrame();
  const logoIn = interpolate(frame, [170, 214], [0, 1], clamp);
  const subtitleIn = interpolate(frame, [224, 252], [0, 1], clamp);
  const finalFade = interpolate(frame, [276, 299], [1, 0], clamp);
  const pulse = 1 + Math.sin(frame * 0.22) * 0.035 * interpolate(frame, [236, 270], [0, 1], clamp);

  return (
    <AbsoluteFill className="bano-overlay" style={{opacity: finalFade}}>
      <div className="bano-final-lockup" style={{opacity: logoIn, transform: `translate(-50%, -50%) scale(${pulse})`}}>
        <Img className="bano-ke-mark" src={staticFile('bano-ke-logo-transparent.png')} />
        <div className="bano-subtitle" style={{opacity: subtitleIn}}>MARBLE BATTLE ARENA</div>
      </div>
      <div className="bano-flash" style={{opacity: interpolate(frame, [158, 175, 205], [0, 0.55, 0], clamp)}} />
    </AbsoluteFill>
  );
};

export const BanoIntro: React.FC = () => {
  return (
    <AbsoluteFill className="bano-intro">
      <BanoThreeScene />
      <LogoOverlay />
    </AbsoluteFill>
  );
};
