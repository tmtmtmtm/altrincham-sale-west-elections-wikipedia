module.exports = (label) => {
  return {
    type: 'item',
    labels: {
      en: label
    },
    claims: {
      P31: { value: 'Q7278' },
      P17: { value: 'Q145' }
    }
  }
}
