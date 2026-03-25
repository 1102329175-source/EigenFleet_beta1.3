import { describe, it, expect } from '@ohos/hypium';
import {
  EigenSolveResult,
  FormationFeasibilityResult,
  evaluateDualQuaternionFormationFeasibility,
  solveDualQuaternionHermitianEigenvalues
} from '../main/ets/utils/EigenSolver';

function diagonalMatrixText(stdDiag: number[], dualDiag: number[]): string {
  const n: number = stdDiag.length;
  const lines: string[] = [];
  for (let i = 0; i < n; i++) {
    const cols: string[] = [];
    for (let j = 0; j < n; j++) {
      if (i === j) {
        cols.push(`${stdDiag[i]},0,0,0,${dualDiag[i]},0,0,0`);
      } else {
        cols.push('0,0,0,0,0,0,0,0');
      }
    }
    lines.push(cols.join(';'));
  }
  return lines.join('\n');
}

function repeatedRootExampleText(): string {
  return '1,0,0,0,0,0,0,0;0,0,0,0,1,0,0,0\n0,0,0,0,1,0,0,0;1,0,0,0,0,0,0,0';
}

function invalidHermitianText(): string {
  return '1,0,0,0,0,0,0,0;1,1,0,0,0,0,0,0\n1,1,0,0,0,0,0,0;2,0,0,0,0,0,0,0';
}

function balancedLaplacianText(): string {
  return '2,0,0,0,0,0,0,0;-1,0,0,0,0,-1,0,0;-1,0,0,0,0,0,0,0\n' +
    '-1,0,0,0,0,1,0,0;2,0,0,0,0,0,0,0;-1,0,0,0,0,1,0,0\n' +
    '-1,0,0,0,0,0,0,0;-1,0,0,0,0,-1,0,0;2,0,0,0,0,0,0,0';
}

function unbalancedLaplacianText(): string {
  return '2,0,0,0,0,0,0,0;-1,0,0,0,0,-1,0,0;-1,0,0,0,0,2,0,0\n' +
    '-1,0,0,0,0,1,0,0;2,0,0,0,0,0,0,0;-1,0,0,0,0,1,0,0\n' +
    '-1,0,0,0,0,-2,0,0;-1,0,0,0,0,-1,0,0;2,0,0,0,0,0,0,0';
}

function nonUnitLaplacianText(): string {
  return '1,0,0,0,0,0,0,0;-2,0,0,0,0,0,0,0\n-2,0,0,0,0,0,0,0;1,0,0,0,0,0,0,0';
}

function wrongDegreeLaplacianText(): string {
  return '5,0,0,0,0,0,0,0;-1,0,0,0,0,0,0,0\n-1,0,0,0,0,0,0,0;1,0,0,0,0,0,0,0';
}

function disconnectedLaplacianText(): string {
  return '0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0';
}

function approx(a: number, b: number, tol: number = 1e-5): boolean {
  return Math.abs(a - b) <= tol;
}

function vectorLooksLikeBasis(item: number[][]): boolean {
  const firstA: number = Math.abs(item[0][0]);
  const secondA: number = Math.abs(item[1][0]);
  return approx(firstA, 1, 1e-4) && approx(secondA, 0, 1e-4);
}

export default function localUnitTest() {
  describe('eigenSolverSupplementMatrix', () => {
    it('solves simple eigenvalues with correct dual parts', 0, () => {
      const result: EigenSolveResult = solveDualQuaternionHermitianEigenvalues(diagonalMatrixText([1, 2], [3, 4]), 2);
      expect(result.ok).assertEqual(true);
      expect(result.items.length).assertEqual(2);
      expect(approx(result.items[0].lambdaS, 1)).assertEqual(true);
      expect(approx(result.items[0].lambdaD, 3)).assertEqual(true);
      expect(approx(result.items[1].lambdaS, 2)).assertEqual(true);
      expect(approx(result.items[1].lambdaD, 4)).assertEqual(true);
    });

    it('uses supplement matrix eigenvectors for repeated roots', 0, () => {
      const result: EigenSolveResult = solveDualQuaternionHermitianEigenvalues(repeatedRootExampleText(), 2);
      expect(result.ok).assertEqual(true);
      expect(result.items.length).assertEqual(2);
      expect(approx(result.items[0].lambdaS, 1)).assertEqual(true);
      expect(approx(result.items[1].lambdaS, 1)).assertEqual(true);
      expect(approx(result.items[0].lambdaD, -1)).assertEqual(true);
      expect(approx(result.items[1].lambdaD, 1)).assertEqual(true);
      expect(vectorLooksLikeBasis(result.items[0].primalVectorComponents)).assertEqual(false);
      expect(vectorLooksLikeBasis(result.items[1].primalVectorComponents)).assertEqual(false);
      expect(approx(Math.abs(result.items[0].primalVectorComponents[0][0]), Math.SQRT1_2, 1e-3)).assertEqual(true);
      expect(approx(Math.abs(result.items[0].primalVectorComponents[1][0]), Math.SQRT1_2, 1e-3)).assertEqual(true);
    });

    it('reports small standard and dual residuals', 0, () => {
      const result: EigenSolveResult = solveDualQuaternionHermitianEigenvalues(repeatedRootExampleText(), 2);
      expect(result.ok).assertEqual(true);
      expect(result.items[0].residualStandard < 1e-6).assertEqual(true);
      expect(result.items[0].residualDual < 1e-6).assertEqual(true);
      expect(result.items[1].residualStandard < 1e-6).assertEqual(true);
      expect(result.items[1].residualDual < 1e-6).assertEqual(true);
    });

    it('rejects non-hermitian input', 0, () => {
      const result: EigenSolveResult = solveDualQuaternionHermitianEigenvalues(invalidHermitianText(), 2);
      expect(result.ok).assertEqual(false);
      expect(result.message.includes('埃尔米特')).assertEqual(true);
    });

    it('formats values with 6 decimals and trims trailing zeros', 0, () => {
      const result: EigenSolveResult = solveDualQuaternionHermitianEigenvalues(diagonalMatrixText([1.23456789, 2], [0.5, 4]), 2);
      expect(result.ok).assertEqual(true);
      expect(result.items[0].lambdaText).assertEqual('1.234568 + 0.5·ε');
      expect(result.items[1].lambdaText).assertEqual('2 + 4·ε');
    });
  });

  describe('formationFeasibility', () => {
    it('accepts balanced DQUGG Laplacian', 0, () => {
      const result: FormationFeasibilityResult = evaluateDualQuaternionFormationFeasibility(balancedLaplacianText(), 3);
      expect(result.ok).assertEqual(true);
      expect(result.feasible).assertEqual(true);
      expect(result.conditions.length).assertEqual(3);
      expect(result.conditions[0].passed).assertEqual(true);
      expect(result.conditions[1].passed).assertEqual(true);
      expect(result.conditions[2].passed).assertEqual(true);
    });

    it('rejects unbalanced DQUGG even when first condition holds', 0, () => {
      const result: FormationFeasibilityResult = evaluateDualQuaternionFormationFeasibility(unbalancedLaplacianText(), 3);
      expect(result.ok).assertEqual(true);
      expect(result.feasible).assertEqual(false);
      expect(result.conditions[0].passed).assertEqual(true);
      expect(result.conditions[1].passed).assertEqual(true);
      expect(result.conditions[2].passed).assertEqual(false);
    });

    it('rejects non-unit edge weights', 0, () => {
      const result: FormationFeasibilityResult = evaluateDualQuaternionFormationFeasibility(nonUnitLaplacianText(), 2);
      expect(result.ok).assertEqual(false);
      expect(result.message.includes('单位对偶四元数')).assertEqual(true);
    });

    it('rejects wrong diagonal degrees', 0, () => {
      const result: FormationFeasibilityResult = evaluateDualQuaternionFormationFeasibility(wrongDegreeLaplacianText(), 2);
      expect(result.ok).assertEqual(false);
      expect(result.message.includes('对角元')).assertEqual(true);
    });

    it('fails condition one when zero eigenvalue multiplicity is larger than one', 0, () => {
      const result: FormationFeasibilityResult = evaluateDualQuaternionFormationFeasibility(disconnectedLaplacianText(), 2);
      expect(result.ok).assertEqual(true);
      expect(result.feasible).assertEqual(false);
      expect(result.conditions[0].passed).assertEqual(false);
    });

    it('returns chinese help text for indicators', 0, () => {
      const result: FormationFeasibilityResult = evaluateDualQuaternionFormationFeasibility(balancedLaplacianText(), 3);
      expect(result.ok).assertEqual(true);
      expect(result.indicators.length > 0).assertEqual(true);
      expect(result.indicators[0].helpText.length > 0).assertEqual(true);
      expect(result.conditions[0].helpText.length > 0).assertEqual(true);
    });
  });
}
