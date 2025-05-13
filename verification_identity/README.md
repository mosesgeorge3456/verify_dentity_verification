# Digital Identity Verification System

A blockchain-based solution for secure digital identity management, verification, and recovery built on the Stacks blockchain.

## Overview

The Digital Identity Verification System provides a decentralized approach to identity management with enhanced security features and trust mechanisms. It enables users to register their digital identities, obtain verification from trusted validators, and recover access through a multi-validator approval process.

## Key Features

- **Identity Registration & Verification**: Users can register their identities and have them verified by the contract owner
- **Two-Factor Authentication**: Enhanced security through optional 2FA enablement
- **Validator Network**: Trusted validators with reputation scores provide identity validation services
- **Identity Recovery**: Secure account recovery mechanism requiring multi-validator approvals
- **Blacklisting Protection**: Protection against malicious actors through admin blacklisting
- **Activity Tracking**: User activity monitoring for security purposes

## Smart Contract Functions

### Identity Management
- `register-identity`: Register a new user identity with name and contact information
- `verify-identity`: Contract owner can verify a user's identity
- `is-verified`: Check if a user's identity is verified
- `enable-two-factor`: Enable two-factor authentication for enhanced security
- `update-activity`: Update a user's last activity timestamp

### Validator Operations
- `register-validator`: Verified users can register as identity validators
- `get-validator-stats`: Retrieve validator reputation statistics

### Administrative Functions
- `blacklist-address`: Contract owner can blacklist suspicious addresses
- `is-blacklisted`: Check if an address is blacklisted
- `advance-block`: Advance the block height (for testing purposes)
- `get-height`: Get the current block height

### Recovery Process
- `initiate-recovery`: Initiate identity recovery to a new address
- `approve-recovery`: Validators can approve a recovery request
- `complete-recovery`: Complete the recovery process after sufficient validator approvals

## Error Codes

- `100`: Not contract owner
- `101`: Identity already registered
- `102`: Identity not registered
- `103`: Identity not verified
- `104`: Not a registered validator
- `105`: No recovery in progress
- `106`: Invalid recovery request
- `108`: Insufficient validator approvals

## Development and Testing

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) - A Clarity runtime packaged as a command-line tool
- [Node.js](https://nodejs.org/) and npm

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/stx-verification-identity.git
   cd stx-verification-identity
   ```

2. Install dependencies:
   ```
   npm install
   ```

### Running Tests

The project uses Vitest for testing. To run the tests:

```
npm test
```

#### Test Structure

The test suite covers all key features of the identity verification system:

1. **Identity Registration**
   - Successful registration
   - Prevention of double registration

2. **Identity Verification**
   - Contract owner verification
   - Restriction of verification to owner only

3. **Two-Factor Authentication**
   - Enabling 2FA for registered users

4. **Block Height Simulation**
   - Block advancement for testing time-based functions

5. **Validator Registration**
   - Registration of verified users as validators
   - Validator stats tracking

6. **Blacklisting**
   - Owner's ability to blacklist malicious addresses
   - Restriction of blacklisting to owner only

7. **Recovery Process**
   - Recovery request initiation
   - Validator approval mechanism
   - Multi-validator approval requirement
   - Recovery completion process

8. **Activity Tracking**
   - User activity timestamp updates

## Security Considerations

- The contract implements owner-based access control for critical functions
- Multi-validator approval ensures secure identity recovery
- Blacklisting capability provides protection against malicious actors
- Two-factor authentication enhances security for individual users
- Activity tracking helps identify unusual activity patterns

## Use Cases

1. **Digital Identity Verification for Financial Services**
   - KYC (Know Your Customer) compliance
   - Anti-money laundering measures

2. **Secure Authentication for Decentralized Applications**
   - Login and access control for dApps
   - Credential management

3. **Recoverable Identity Systems**
   - Secure recovery path for lost credentials
   - Protection against permanent loss of access

4. **Reputation-Based Trust Systems**
   - Validator reputation tracking
   - Trust score for identity verifications

## Future Enhancements

- Integration with decentralized identity standards (DID)
- Zero-knowledge proof implementations for enhanced privacy
- Tiered validation levels for different security requirements
- Cross-chain identity verification
- Integration with biometric verification methods

## License

This project is licensed under the MIT License - see the LICENSE file for details.